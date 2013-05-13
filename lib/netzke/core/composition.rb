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

    included do
      # Declares Base.component, for declaring child componets, and Base#components, which returns a [Hash] of all component configs by name
      declare_dsl_for :components

      # Loads a component on browser's request. Every Netzke component gets this endpoint.
      # <tt>params</tt> should contain:
      # * <tt>:cache</tt> - an array of component classes cached at the browser
      # * <tt>:id</tt> - reference to the component
      # * <tt>:container</tt> - Ext id of the container where in which the component will be rendered
      endpoint :deliver_component do |params, this|
        cache = params[:cache].split(",") # array of cached xtypes
        component_name = params[:name].underscore.to_sym

        cmp_instance = components[component_name] &&
          !components[component_name][:excluded] &&
          component_instance(component_name, {js_id: params[:id], client_config: params[:client_config]})

        if cmp_instance
          js, css = cmp_instance.js_missing_code(cache), cmp_instance.css_missing_code(cache)
          this.netzke_eval_js(js) if js.present?
          this.netzke_eval_css(css) if css.present?

          this.netzke_component_delivered(cmp_instance.js_config.merge(loading_id: params[:loading_id]));
        else
          this.netzke_component_delivery_failed(component_name: component_name, msg: "Couldn't load component '#{component_name}'", loading_id: params[:loading_id])
        end
      end

    end # included

    # @return [Hash] configs of eagerly loaded components by name
    def eagerly_loaded_components
      @eagerly_loaded_components ||= components.select{|k,v| components_in_config.include?(k) || v[:eager_loading]}
    end

    # @return [Array<Symbol>] components (by name) referred in config (and thus, required to be instantiated)
    def components_in_config
      @components_in_config || (normalize_config || true) && @components_in_config
    end

    # Recursively instantiates a child component based on its "path": e.g. if we have component :component1 which in its turn has component :component2, the path to the latter would be "component1__component2"
    # @param name [Symbol] component name
    def component_instance(name, strong_config = {})
      name.to_s.split('__').inject(self) do |out, cmp_name|
        cmp_config = out.components[cmp_name.to_sym]
        raise ArgumentError, "No component '#{cmp_name}' defined for '#{out.js_id}'" if cmp_config.nil? || cmp_config[:excluded]
        cmp_config[:name] = cmp_name
        cmp_config.merge!(strong_config)
        cmp_config[:klass].new(cmp_config, out)
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

    def extend_item(item)
      item = detect_and_normalize(:component, item)
      @components_in_config << item[:netzke_component] if include_component?(item)
      super item
    end

  private

    def include_component?(cmp_config)
      cmp_config.is_a?(Hash) &&
        cmp_config[:netzke_component] &&
        cmp_config[:eager_loading] != false &&
        !cmp_config[:excluded]
    end
  end
end
