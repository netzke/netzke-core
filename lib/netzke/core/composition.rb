module Netzke::Core
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
  # A child component can be referred in the layout by using symbols:
  #
  #     component :users do |c|
  #       c.title = "A Netzke component"
  #     end
  #
  #     def configure(c)
  #       super
  #       c.items = [
  #         { xtype: :panel, title: "Simple Ext panel" },
  #         :users # a Netzke component
  #       ]
  #     end
  #
  # If an extra (layout) configuration should be provided, a component can be referred to by using the +component+ key in the configuration hash (this can be useful when overriding a layout of a child component):
  #
  #     component :tab_one # ...
  #     component :tab_two # ...
  #
  #     def configure(c)
  #       super
  #       c.items = [
  #         {component: :tab_one, title: "One"},
  #         {component: :tab_two, title: "Two"}
  #       ]
  #     end
  #
  # == Lazily vs eagerly loaded components
  #
  # By default, if a component is not used in the layout, it is lazily loaded, which means that the code for this component is not loaded in the browser until the moment the component gets dynamically loaded by the JavaScript method `netzkeLoadComponent` (see {Netzke::Core::Javascript}). Referring a component in the layout (the `items` property) automatically makes it eagerly loaded. Sometimes it's desired to eagerly load a component without using it directly in the layout (an example can be a window that we need to render instantly without requesting the server). In this case an option `eager_loading` can be set to true:
  #
  #     component :eagerly_loaded_window do |c|
  #       c.klass = SomeWindowComponent
  #       c.eager_loading = true
  #     end
  #
  # == Dynamic component loading
  #
  # Child components can be dynamically loaded by using client class' +netzkeLoadComponent+ method (see {javascript/ext.js}[https://github.com/netzke/netzke-core/blob/master/javascripts/ext.js] for inline documentation):
  #
  # == Excluded components
  #
  # You can make a child component inavailable for dynamic loading by using the +excluded+ option. When an excluded component is used in the layout, it will be skipped.
  # This can be used for authorization.
  module Composition
    extend ActiveSupport::Concern

    COMPONENT_METHOD_NAME = "%s_component"


    included do

      # Returns registered components
      class_attribute :registered_components
      self.registered_components = []

      # @!method Foobar
      # Loads a component on browser's request. Every Netzke component gets this endpoint.
      # <tt>params</tt> should contain:
      # * <tt>:cache</tt> - an array of component classes cached at the browser
      # * <tt>:id</tt> - reference to the component
      # * <tt>:container</tt> - Ext id of the container where in which the component will be rendered
      endpoint :deliver_component do |params, this|
        cache = params[:cache].split(",") # array of cached xtypes
        component_name = params[:name].underscore.to_sym
        component = components[component_name] && !components[component_name][:excluded] && component_instance(component_name)

        if component
          js, css = component.js_missing_code(cache), component.css_missing_code(cache)
          this.netzke_eval_js(js) if js.present?
          this.netzke_eval_css(css) if css.present?

          this.netzke_component_delivered(component.js_config);
        else
          this.netzke_component_delivery_failed(component_name: component_name, msg: "Couldn't load component '#{component_name}'")
        end
      end

    end # included

    module ClassMethods

      # Declares a child (nested) component.
      # @param name [Symbol] component name
      # @param block [Proc] config block
      # @example
      #   component :users do |c|
      #     c.klass = Netzke::Basepack::Grid
      #     c.modul = "User"
      #   end
      def component(name, &block)
        self.registered_components |= [name]

        method_name = COMPONENT_METHOD_NAME % name
        if block_given?
          define_method(method_name, &block)
        else
          define_method(method_name) do |component_config|
            component_config
          end
        end
      end
    end

    # @return [Hash] component configs by name
    def components
      @components ||= self.class.registered_components.inject({}) do |out, name|
        component_config = Netzke::Core::ComponentConfig.new(name)
        send(COMPONENT_METHOD_NAME % name, component_config)
        component_config.set_defaults!
        if component_config.excluded
          out.merge(name.to_sym => {excluded: true})
        else
          out.merge(name.to_sym => component_config)
        end
      end
    end

    # @return [Hash] configs of eagerly loaded components by name
    def eagerly_loaded_components
      @eagerly_loaded_components ||= components.select{|k,v| components_in_config.include?(k) || v[:eager_loading]}
    end

    # @return [Array<Symbol>] components (by name) referred in config (and thus, required to be instantiated)
    def components_in_config
      @components_in_config || (normalize_config || true) && @components_in_config
    end

    # Called when the method_missing tries to processes a non-existing component. Override when needed.
    def component_missing(aggr)
      flash :error => "Unknown component #{aggr} for #{name}"
      {:feedback => @flash}.to_nifty_json
    end

    # Recursively instantiates a child component based on its "path": e.g. if we have component :component1 which in its turn has component :component2, the path to the latter would be "component1__component2"
    # @param name [Symbol] component name
    def component_instance(name)
      raise ArgumentError, "No component '#{name.inspect}' defined for '#{self.js_id}'" if !name.present?

      @component_instance_cache ||= {}
      @component_instance_cache[name] ||= begin
        composite = self
        name.to_s.split('__').each do |cmp|
          cmp = cmp.to_sym

          component_config = composite.components[cmp]
          raise ArgumentError, "No component '#{cmp}' defined for '#{composite.js_id}'" if component_config.nil? || component_config[:excluded]

          klass = component_config[:klass]

          instance_config = component_config.merge(:name => cmp)

          composite = klass.new(instance_config, composite) # params: config, parent
        end
        composite
      end
    end

    # @return [Array<Class>] All component classes that we depend on (used to render all necessary javascripts and stylesheets)
    def dependency_classes
      res = []

      eagerly_loaded_components.keys.each do |aggr|
        res += component_instance(aggr).dependency_classes
      end

      res += self.class.netzke_ancestors
      res.uniq
    end

    # JS id of a component in the hierarchy, based on passed reference that follows the double-underscore notation. Referring to "parent" is allowed. If going to far up the hierarchy will result in <tt>nil</tt>, while referring to a non-existent component will simply provide an erroneous ID.
    # For example:
    # <tt>parent__parent__child__subchild</tt> will traverse the hierarchy 2 levels up, then going down to "child", and further to "subchild". If such a component exists in the hierarchy, its global id will be returned, otherwise <tt>nil</tt> will be returned.
    # @param ref [Symbol] reference to a child component
    # @return [String] JS id
    def js_id_by_reference(ref)
      ref = ref.to_s
      return parent && parent.js_id if ref == "parent"
      substr = ref.sub(/^parent__/, "")
      if substr == ref # there's no "parent__" in the beginning
        return js_id + "__" + ref
      else
        return parent.js_id_by_reference(substr)
      end
    end

  protected

    # During normalization of the config object, this method is being called with each item found (recursively) in there.
    # For example, symbols representing nested child components get replaced with a proper config hash. Same goes for actions.
    # Override to do any additional checks/enhancements. See, for example, +Netzke::Basepack::WrapLazyLoaded+.
    # @return [Object] extended item
    def extend_item(item)
      # in a situation of action and component being equally named, action will take precedence

      if item.is_a?(Symbol) && item_config = actions[item]
        item = {netzke_action: item}
      elsif item.is_a?(Symbol) && item_config = components[item]
        item = {netzke_component: item}
      end

      item[:excluded] = true if item_config && item_config[:excluded]

      if item.is_a?(Hash)
        return nil if item[:excluded] # it'll get compacted away by Array#deep_map

        # replace the `component` and `action` keys with `netzke_component` and `netzke_action`, which will be looked for at the JS side
        item[:netzke_action] = item.delete(:action) if item[:action]
        item[:netzke_component] = item.delete(:component) if item[:component]

        @components_in_config << item[:netzke_component] if item[:netzke_component] && item[:eager_loading] != false
      end

      item
    end

  private

    # We'll build a couple of useful instance variables here:
    #
    # +components_in_config+ - an array of components (by name) referred in items
    # +normalized_config+ - a config that has all the config extensions applied
    def normalize_config
      @components_in_config = []
      @normalized_config = config.dup.tap do |c|
        c.each_pair do |k,v|
          c.delete(k) if self.class.server_side_config_options.include?(k.to_sym)
          c[k] = v.deep_map{|el| extend_item(el)} if v.is_a?(Array)
        end
      end
    end

    # @return [Hash] config with all placeholders (like child components referred by symbols) expanded
    def normalized_config
      # make sure we call normalize_config first
      @normalized_config || (normalize_config || true) && @normalized_config
    end

  end
end
