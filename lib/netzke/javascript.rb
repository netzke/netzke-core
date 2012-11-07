module Netzke
  # == JavaScript class generation
  #
  # (For class-level DSL methods mentioned here see {ClassMethods})
  #
  # Each component operates on both client and server side. At the server side it's represented (naturally) by a Ruby class, at the client side it's represented by a corresponding JavaScript class. The JavaScript class extends the Ext JS class specified by +js_base_class+, or, in case of extending an existing Netzke component, that component's JavaScript class.
  #
  # A component can "mixin" a JavaScript object from a .js file into its class by using the +js_mixin+ +method+.
  #
  # When the component has some extra JavaScript code as dependency, this can be included by using +js_include+ method.
  #
  # Defining JavaScript class-level properties (besides putting them right into a JavaScript mixin) is possible in Ruby by using the +js_property+ and +js_properties+ methods.
  #
  # An example of using these methods:
  #
  #     class MyTabPanel < Netzke::Base
  #       js_base_class "Ext.tab.Panel"
  #       js_mixin :extra_properties # mixin my_component/javascripts/extra_properties.js
  #       js_include :some_javascript_dependency # include my_component/javascripts/some_javascript_dependency.js
  #       js_property :active_tab, 0 # this could also be defined in extra_properties.js
  #       # ...
  #     end
  #
  # == JavaScript class instantiation
  #
  # The JavaScript class gets instantiated with the config object defined by the +js_config+ method as constructor parameter.
  #
  # == JavaScript instance methods
  #
  # The following public JavaScript methods are defined on (mixed-in into) all Netzke components (for detailed documentation on them see the inline documentation in javascript/base.js and javascript/ext.js files):
  # * loadNetzkeComponent - dynamically loads a child Netzke component
  # * instantiateChildNetzkeComponent - instantiates and returns a Netzke component by its item_id
  # * netzkeFeedback - shows a feedback message
  # * componentNotInSession - gets called when the session that the component is defined in gets expired. Override it to do whatever is appropriate.
  #
  # TODO: update docs
  module Javascript
    extend ActiveSupport::Concern

    module ClassMethods

      # Configures JS class
      # Example:
      #   js_configure do |c|
      #     # c is an instance of ClientClass
      #     c.title = "My title"
      #     c.mixin
      #     c.include :extra_js
      #     # ...etc
      #   end
      def js_configure &block
        block.call(js_config)
      end

      def js_config
        @_js_config ||= Netzke::Core::ClientClass.new(self)
      end

    end

    # The result of this method (a hash) is converted to a JSON object and passed as options to the constructor of our JavaScript class.
    def js_config
      @js_config ||= ActiveSupport::OrderedOptions.new.tap{|c| js_configure(c)}
    end

    # Object containing configuration for all child components to be instantiated at the JS side
    def js_components
      @js_components ||= eagerly_loaded_components.inject({}) do |out, (name, config)|
        instance = component_instance(name.to_sym)
        out.merge(name => instance.js_config)
      end
    end

    # The `js_configure' method should be used to override the JS-side component configuration. It is called by the framework when the configuration for the JS instantiating of the component should be retrieved. Thus, it's *not* being called when a component is being instantiated to process an endpoint call.
    #
    # Override it when you need to extend/modify the config for the JS component intance.
    def js_configure(c)
      # Merge in component config options, besides those that are only meant for the server side
      # c.merge!(config.reject{ |k,v| self.class.server_side_config_options.include?(k.to_sym) })
      c.merge!(normalized_config)

      # Unique id of the component
      c.id = js_id

      # Configuration for all of our non-lazy-loaded children specified here. We can refer to them in +items+ so they get instantiated by Ext.
      c.netzke_components = js_components unless js_components.empty?

      # Endpoints (besides the default "deliver_component" - JavaScript side already knows about it)
      endpoints = self.class.endpoints.keys - [:deliver_component]

      # pass them as strings, not as symbols
      c.endpoints = endpoints.map(&:to_s) unless endpoints.empty?

      # Inform the JavaScript side if persistent_config is enabled
      # res[:persistent_config] = persistence_enabled?

      # Include our xtype
      c.xtype = self.class.js_config.xtype

      # Include our alias: Ext.createByAlias may be used to instantiate the component.
      c.alias = self.class.js_config.class_alias

      # So we can use getComponent(<component_name>) to retrieve a child component
      c.item_id ||= name

      c.i18n = js_translate_properties if js_translate_properties.present?

      c.netzke_plugins = plugins.map{ |p| p.to_s.camelcase(:lower) } if plugins.present?

      # we need to pass them as strigs, not as symbols
      c.tools = c.tools.map(&:to_s) if c.tools.present?

      c.flash = session[:flash] if session[:flash].present?
    end

    # All the JS-code required by this instance of the component to be instantiated in the browser.
    # It includes JS-classes for the parents, non-lazy-loaded child components, and itself.
    def js_missing_code(cached = [])
      code = dependency_classes.inject("") do |r,k|
        cached.include?(k.js_config.xtype) ? r : r + k.js_config.js_code#.strip_js_comments
      end
      code.blank? ? nil : code
    end

  protected

    # Merges all the translations in the class hierarchy
    # Note: this method can't be moved out to JsClass, because I18n is loaded only once, when other classes are evaluated; so, this must stay at instance level.
    def js_translate_properties
      @js_translate_properties ||= self.class.class_ancestors.inject({}) do |r,klass|
        hsh = klass.js_config.translated_properties.inject({}) { |h,t| h.merge(t => I18n.t("#{klass.i18n_id}.#{t}")) }
        r.merge(hsh)
      end
    end

  end
end
