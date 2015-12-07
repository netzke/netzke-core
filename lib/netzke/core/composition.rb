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
  # If extra (layout) configuration is needed, a component can be referred to by using the +component+ key in the configuration hash (this can be useful when overriding a layout of a child component):
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
  # By default, if a component is not used in the layout, it is lazily loaded, which means that the code for this component is not loaded in the browser until the moment the component gets dynamically loaded by the JavaScript method `nzLoadComponent` (see {Netzke::Core::ClientCode}). Referring a component in the layout (the `items` property) automatically makes it eagerly loaded. Sometimes it's desired to eagerly load a component without using it directly in the layout (an example can be a window that we need to render instantly without requesting the server). In this case an option `eager_loading` can be set to true:
  #
  #     component :eagerly_loaded_window, eager_loading: true do |c|
  #       c.klass = SomeWindowComponent
  #     end
  #
  # == Dynamic component loading
  #
  # Child components can be dynamically loaded by using client class' +nzLoadComponent+ method (see {javascript/ext.js}[https://github.com/netzke/netzke-core/blob/master/javascripts/ext.js] for inline documentation):
  #
  # == Excluded components
  #
  # You can make a child component inavailable for dynamic loading by using the +excluded+ option. When an excluded component is used in the layout, it will be skipped.
  # This can be used for authorization.
  module Composition
    extend ActiveSupport::Concern

    module ClassMethods
      def component(name, options = {}, &block)
        define_method :"#{name}_component", &(block || ->(c){c})
        # NOTE: "<<" won't work here as this will mutate the array shared between classes
        self.eagerly_loaded_dsl_components += [name] if options[:eager_loading]
      end
    end

    included do
      # Hash of components declared inline in the config
      attr_accessor :inline_components

      # Components declared in DSL and marked with `eager_loading: true`
      class_attribute :eagerly_loaded_dsl_components
      self.eagerly_loaded_dsl_components = []

      # Loads a component on browser's request. Every Netzke component gets this endpoint.
      # +params+ should contain:
      #   [cache] an array of component classes cached at the browser
      #   [name] name of the child component to be loaded
      #   [index] clone index of the loaded component
      endpoint :deliver_component do |params|
        cache = params[:cache].split(",") # array of cached xtypes
        component_name = params[:name].underscore.to_sym

        item_id = params[:item_id]
        cmp_instance = component_instance(component_name, {item_id: item_id, client_config: params[:client_config]})

        if cmp_instance
          js, css = cmp_instance.js_missing_code(cache), cmp_instance.css_missing_code(cache)
          { js: js, css: css, config: cmp_instance.js_config }
        else
          { error: "Couldn't load component '#{component_name}'" }
        end
      end
    end # included

    # @return [Array] names of eagerly loaded components
    def eagerly_loaded_components
      self.class.eagerly_loaded_dsl_components + @components_in_config
    end

    # Instantiates a child component by its name.
    # +params+ can contain:
    #   [client_config] a config hash passed from the client class
    #   [item_id] overridden item_id, used in case of loading multiple instances of the same child component
    def component_instance(name, overrides = {})
      cfg = component_config(name, overrides)
      return nil if cfg.nil? || cfg[:excluded]
      klass = cfg.klass || cfg.class_name.constantize
      klass.new(cfg, self)
    end

    # @return [Hash] Given component's name and overrides, returns complete component's config, ready for
    # instantiation
    def component_config(component_name, overrides = {})
      return nil if component_name.nil?

      component_name = component_name.to_sym

      ComponentConfig.new(component_name, self).tap do |cfg|
        cfg.client_config = overrides[:client_config] || {}
        cfg.item_id = overrides[:item_id]

        if respond_to?(:"#{component_name}_component")
          send("#{component_name}_component", cfg)
        elsif inline_components[component_name]
          cfg.merge!(inline_components[component_name])
        else
          return nil
        end

        cfg.set_defaults!
      end
    end

    # @return [Array<Class>] All component classes that we depend on (used to render all necessary javascripts and stylesheets)
    def dependency_classes
      res = []

      eagerly_loaded_components.each do |aggr|
        res += component_instance(aggr).dependency_classes
      end

      res += self.class.netzke_ancestors
      res.uniq
    end

    def extend_item(item)
      super detect_and_normalize_component(item)
    end

  private

    def detect_and_normalize_component(item)
      item = {component: item} if item.is_a?(Symbol) && respond_to?(:"#{item}_component")
      return item unless item.is_a?(Hash)
      return nil if item[:excluded]

      if item[:klass] || item[:class_name]
        # declared inline
        item_id = item[:item_id] || :"component_#{@implicit_component_index}"
        @implicit_component_index += 1
        # components[item_id] = item
        inline_components[item_id.to_sym] = item
        @components_in_config << item_id
        {netzke_component: item_id}
      elsif item_id = item.delete(:component)
        return nil if component_config(item_id)[:excluded]
        @components_in_config << item_id
        item.merge(netzke_component: item_id)
      else
        item
      end
    end
  end
end
