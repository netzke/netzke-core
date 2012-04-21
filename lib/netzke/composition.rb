module Netzke
  # This module takes care of components composition.
  #
  # You can define a nested component by calling the +component+ class method:
  #
  #     component :users, :data_class => "GridPanel", :model => "User"
  #
  # The method also accepts a block in case you want access to the component's instance:
  #
  #     component :books do
  #       {:data_class => "Book", :title => build_title}
  #     end
  #
  # To override a component, define a method {component_name}_component, e.g.:
  #
  #     def books_component
  #       super.merge(:title => "Modified Title")
  #     end
  module Composition
    extend ActiveSupport::Concern

    COMPONENT_METHOD_NAME = "%s_component"

    included do

      # Returns registered components
      class_attribute :registered_components
      self.registered_components = []

      # Loads a component on browser's request. Every Netzke component gets this endpoint.
      # <tt>params</tt> should contain:
      # * <tt>:cache</tt> - an array of component classes cached at the browser
      # * <tt>:id</tt> - reference to the component
      # * <tt>:container</tt> - Ext id of the container where in which the component will be rendered
      endpoint :deliver_component do |params|
        cache = params[:cache].split(",") # array of cached xtypes
        component_name = params[:name].underscore.to_sym
        component = components[component_name] && component_instance(component_name)

        if component
          # inform the component that it's being loaded
          component.before_load

          [{
            :eval_js => component.js_missing_code(cache),
            :eval_css => component.css_missing_code(cache)
          }, {
            :component_delivered => component.js_config
          }]
        else
          {:component_delivery_failed => {:component_name => component_name, :msg => "Couldn't load component '#{component_name}'"}}
        end
      end

    end # included

    module ClassMethods

      # Defines a nested component.
      def component_DELETEME(name, config = {}, &block)
        register_component(name)
        config = config.dup
        config[:class_name] ||= name.to_s.camelize
        config[:name] = name.to_s
        method_name = COMPONENT_METHOD_NAME % name

        if block_given?
          define_method(method_name, &block)
        else
          if superclass.instance_methods.map(&:to_s).include?(method_name)
            define_method(method_name) do
              super().merge(config)
            end
          else
            define_method(method_name) do
              config
            end
          end
        end
      end

      def component(name, &block)
        register_component(name)

        method_name = COMPONENT_METHOD_NAME % name
        if block_given?
          define_method(method_name, &block)
        else
          define_method(method_name) do |component_config|
            component_config
          end
        end
      end

      # DEPRECATED in favor of Symbol#component
      # Component's js config used when embedding components as Container's items
      # (see some_composite.rb for an example)
      def js_component(name, config = {})
        ::ActiveSupport::Deprecation.warn("Using js_component is deprecated. Use Symbol#component instead", caller)
        config.merge(:component => name)
      end

      # Register a component
      def register_component(name)
        self.registered_components |= [name]
      end

    end

    # Override this to specify the layout of the component
    def items
      #@items_with_normalized_components
      []
    end

    # DEPRECATED in favor of Base.component
    def initial_components
      {}
    end

    # All components for this instance, which includes components defined on class level, and components detected in :items
    def components
      #@components ||= self.class.registered_components.inject({}){ |res, name| res.merge(name.to_sym => send(COMPONENT_METHOD_NAME % name)) }.merge(config[:components] || {})
      @components ||= self.class.registered_components.inject({}) do |res, name|
        component_config = Netzke::ComponentConfig.new(name, self)
        send(COMPONENT_METHOD_NAME % name, component_config)
        component_config.delete(:lazy_loading) if component_config.lazy_loading == true && eagerly_loaded_components_referred_in_items.include?(name)
        res.merge(name.to_sym => component_config)
      end
    end

    def eager_loaded_components
      components.reject{|k,v| v[:lazy_loading]}
    end

    # An array of component's names that are being referred in items and should be eagerly loaded
    def eagerly_loaded_components_referred_in_items
      @eagerly_loaded_components_referred_in_items ||= [].tap do |r|
        traverse_components_in_items(config.items || items){ |c| r << c[:netzke_component] if c[:lazy_loading] != true }
      end
    end

    # DEPRECATED
    def add_component(aggr)
      components.merge!(aggr)
    end

    # DEPRECATED
    def remove_component(aggr)
      if config[:persistent_config]
        persistence_manager_class.delete_all_for_component("#{global_id}__#{aggr}")
      end
      components[aggr] = nil
    end

    # Called when the method_missing tries to processes a non-existing component
    def component_missing(aggr)
      flash :error => "Unknown component #{aggr} for component #{name}"
      {:feedback => @flash}.to_nifty_json
    end

    # Recursively instantiates a component based on its "path": e.g. if we have component :component1 which in its turn has component :component2, the path to the latter would be "component1__component2"
    # TODO: strong_config should probably be thrown away, and is not taken into account when caching the results
    def component_instance(name, strong_config = {})
      @component_instance_cache ||= {}
      @component_instance_cache[name] ||= begin
        composite = self
        name.to_s.split('__').each do |cmp|
          cmp = cmp.to_sym

          component_config = composite.components[cmp]
          raise ArgumentError, "No child component '#{cmp}' defined for component '#{composite.global_id}'" if component_config.nil?

          klass = component_config[:klass]
          raise ArgumentError, "No class specified for component #{cmp} of #{composite.global_id}" if klass.nil?

          instance_config = weak_children_config.merge(component_config).merge(strong_config).merge(:name => cmp)

          composite = klass.new(instance_config, composite) # params: config, parent
        end
        composite
      end
    end

    # All components that we depend on (used to render all necessary JavaScript and stylesheets)
    def dependency_classes
      res = []

      eager_loaded_components.keys.each do |aggr|
        res += component_instance(aggr).dependency_classes
      end

      res += self.class.class_ancestors

      res << self.class
      res.uniq
    end

    # DEPRECATED
    def js_component(*args)
      self.class.js_component(*args)
    end

    # Returns global id of a component in the hierarchy, based on passed reference that follows
    # the double-underscore notation. Referring to "parent" is allowed. If going to far up the hierarchy will
    # result in <tt>nil</tt>, while referring to a non-existent component will simply provide an erroneous ID.
    # Example:
    # <tt>parent__parent__child__subchild</tt> will traverse the hierarchy 2 levels up, then going down to "child",
    # and further to "subchild". If such a component exists in the hierarchy, its global id will be returned, otherwise
    # <tt>nil</tt> will be returned.
    def global_id_by_reference(ref)
      ref = ref.to_s
      return parent && parent.global_id if ref == "parent"
      substr = ref.sub(/^parent__/, "")
      if substr == ref # there's no "parent__" in the beginning
        return global_id + "__" + ref
      else
        return parent.global_id_by_reference(substr)
      end
    end

  protected

    # Yields each Netzke component config found in items (recursively)
    def traverse_components_in_items(items, &block)
      items.each do |item|
        yield(item) if is_component_config?(item)
        traverse_components_in_items(item[:items], &block) if item[:items]
      end
    end

    def is_component_config?(c) #:nodoc:
      c.is_a?(Symbol) || c.is_a?(Hash) && c[:netzke_component]
    end

  end
end
