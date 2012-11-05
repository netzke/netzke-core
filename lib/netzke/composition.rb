module Netzke
  # Any Netzke component can define child components, which can either be statically nested in the compound layout (e.g. as different regions of the 'border' layout), or dynamically loaded at a request (as is the advanced search panel in Basepack::GridPanel, for example).
  #
  # == Defining a component
  #
  # You can define a child component by calling the +component+ class method which normally requires a block:
  #
  #     component :users do |c|
  #       c.klass = GridPanel
  #       c.model = "User"
  #       c.title = "Users"
  #     end
  #
  # If no configuration is required, and the component's class name can be derived from its name, then the block can be omitted, e.g.:
  #
  #     component :user_grid
  #
  # which is equivalent to:
  #
  #     component :user_grid do |c|
  #       c.klass = UserGrid
  #     end
  #
  # == Overriding a component
  #
  # When overriding a component, the `super` method should be called, with the configuration object passed to it as parameter:
  #
  #     component :users do |c|
  #       super(c)
  #       c.title = "Modified Title"
  #     end
  #
  # == Referring to components in layouts
  #
  # When a child component is to be used in the layout, it can be referred by using the `netzke_component` key in the configuration hash:
  #
  #     def configure(c)
  #       super
  #       c.items = [
  #         { xtype: :panel, title: "Simple Ext panel" },
  #         { netzke_component: :users, title: "A Netzke component" }
  #       ]
  #     end
  #
  # If no extra (layout) configuration is needed, a component can be simply referred by using a symbol, e.g.:
  #
  #     component :tab_one # ...
  #     component :tab_two # ...
  #
  #     def configure(c)
  #       super
  #       c.items = [:tab_one, :tab_two]
  #     end
  #
  # == Lazily vs eagerly loaded components
  #
  # By default, if a component is not used in the layout, it is lazily loaded, which means that the code for this component is not loaded in the browser until the moment the component gets dynamically loaded by the JavaScript method `loadNetzkeComponent` (see {Netzke::Javascript}). Referring a component in the layout (the `items` property) automatically makes it eagerly loaded. Sometimes it's desired to eagerly load a component without using it directly in the layout (an example can be a window that we need to render instantly without requesting the server). In this case an option `eager_loading` can be set to true:
  #
  #     component :eagerly_loaded_window do |c|
  #       c.klass = SomeWindowComponent
  #       c.eager_loading = true
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
      endpoint :deliver_component do |params, this|
        cache = params[:cache].split(",") # array of cached xtypes
        component_name = params[:name].underscore.to_sym
        component = components[component_name] && component_instance(component_name)

        if component
          js, css = component.js_missing_code(cache), component.css_missing_code(cache)
          this.eval_js(js) if js.present?
          this.eval_css(css) if css.present?

          this.component_delivered(component.js_config);
        else
          this.component_delivery_failed(component_name: component_name, msg: "Couldn't load component '#{component_name}'")
        end
      end

    end # included

    module ClassMethods

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

      # Register a component
      def register_component(name)
        self.registered_components |= [name]
      end

    end

    # All components for this instance, which includes components defined on class level, and components detected in :items
    def components
      @components ||= self.class.registered_components.inject({}) do |out, name|
        component_config = Netzke::ComponentConfig.new(name, self)
        send(COMPONENT_METHOD_NAME % name, component_config)
        out.merge(name.to_sym => component_config)
      end
    end

    def eagerly_loaded_components
      @eagerly_loaded_components ||= components.select{|k,v| components_in_config.include?(k) || v[:eager_loading]}
    end

    # Array of components (by name) referred in config (and thus, required to be instantiated)
    def components_in_config
      @components_in_config || (normalize_config || true) && @components_in_config
    end

    # Called when the method_missing tries to processes a non-existing component. Override when needed.
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

          klass = component_config[:klass] || Netzke::Core::Panel

          instance_config = {}.merge(component_config).merge(strong_config).merge(:name => cmp)

          composite = klass.new(instance_config, composite) # params: config, parent
        end
        composite
      end
    end

    # All components that we depend on (used to render all necessary JavaScript and stylesheets)
    def dependency_classes
      res = []

      eagerly_loaded_components.keys.each do |aggr|
        res += component_instance(aggr).dependency_classes
      end

      res += self.class.class_ancestors

      res << self.class
      res.uniq
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
        yield(:netzke_component => item) if item.is_a?(Symbol)
        yield(item) if item.is_a?(Hash) && item[:netzke_component]

        traverse_components_in_items(item[:items], &block) if item.is_a?(Hash) && item[:items]
      end
    end

    def extend_item(item)
      item = {netzke_component: item} if item.is_a?(Symbol) && components[item]
      item = {netzke_action: item} if item.is_a?(Symbol) && actions[item]

      if item.is_a?(Hash)
        @components_in_config << item[:netzke_component] if item[:netzke_component] && item[:eager_loading] != false
      end

      item
    end

    # We'll build a few useful instance variables here:
    #
    # @components_in_config - an array of those components (by name) that are referred in items
    # @normalized_config - a config that has all the extensions (duh...)
    def normalize_config
      @components_in_config = []
      @normalized_config = config.dup.tap do |c|
        c.each_pair do |k,v|
          c.delete(k) if self.class.server_side_config_options.include?(k.to_sym)
          c[k] = v.deep_map{|el| extend_item(el)} if v.is_a?(Array)
        end
      end
    end

    def normalized_config
      # make sure we call normalize_config first
      @normalized_config || (normalize_config || true) && @normalized_config
    end

  end
end
