module Netzke::Core
  # Client class definition and instantiation.
  #
  # == JavaScript instance methods
  #
  # The following public JavaScript methods are defined on (mixed-in into) all Netzke components (for detailed documentation on them see the inline documentation in javascript/base.js and javascript/ext.js files):
  # * netzkeLoadComponent - dynamically loads a child Netzke component
  # * netzkeInstantiateComponent - instantiates and returns a Netzke component by its item_id
  # * netzkeFeedback - shows a feedback message
  # * componentNotInSession - gets called when the session that the component is defined in gets expired. Override it to do whatever is appropriate.
  module Javascript
    extend ActiveSupport::Concern

    module ClassMethods
      # Configures JS class
      # Example:
      #
      #   js_configure do |c|
      #     # c is an instance of ClientClass
      #     c.title = "My title"
      #     c.mixin
      #     c.require :extra_js
      #     # ...etc
      #   end
      #
      # For more details see {Netzke::Core::ClientClass}
      def js_configure &block
        @js_configure_blocks ||= []
        @js_configure_blocks << block
      end

      # Class-level client class config
      def js_config
        return @js_config if @js_config.present?
        @js_config = Netzke::Core::ClientClass.new(self)
        @js_config.tap do |c|
          (@js_configure_blocks || []).each{|block| block.call(c)}
        end
      end
    end

    # Builds {#js_config} used for instantiating a client class. Override it when you need to extend/modify the config for the JS component intance. It's *not* being called when the *server* class is being instantiated (e.g. to process an endpoint call). With other words, it's only being called before a component is first being loaded in the browser. so, it's ok to do heavy stuf fhere, like building a tree panel nodes from the database.
    def js_configure(c)
      c.merge!(normalized_config)

      # Unique id of the component
      c.id = js_id

      # Configuration for all of our non-lazy-loaded children specified here. We can refer to them in +items+ so they get instantiated by Ext.
      c.netzke_components = js_components unless js_components.empty?

      # Endpoints (besides the default "deliver_component" - JavaScript side already knows about it)
      endpoints = self.class.endpoints.keys - [:deliver_component]

      # pass them as strings, not as symbols
      c.endpoints = endpoints.map(&:to_s) unless endpoints.empty?

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

      c.flash = session[:flash] if session && session[:flash].present?
    end

    # Instance-level client class config. The result of this method (a hash) is converted to a JSON object and passed as options to the constructor of our JavaScript class.
    # Not to be overridden, override {#js_configure} instead.
    def js_config
      @js_config ||= ActiveSupport::OrderedOptions.new.tap{|c| js_configure(c)}
    end

    # Hash containing configuration for all child components to be instantiated at the JS side
    def js_components
      @js_components ||= eagerly_loaded_components.inject({}) do |out, (name, config)|
        instance = component_instance(name.to_sym)
        out.merge(name => instance.js_config)
      end
    end

    # All the JS-code required by this instance of the component to be instantiated in the browser.
    # It includes JS-classes for the parents, eagerly loaded child components, and itself.
    def js_missing_code(cached = [])
      code = dependency_classes.inject("") do |r,k|
        cached.include?(k.js_config.xtype) ? r : r + k.js_config.code_with_dependencies
      end
      code.blank? ? nil : Netzke::Core::DynamicAssets.strip_js_comments(code)
    end

  private

    # Merges all the translations in the class hierarchy
    # Note: this method can't be moved out to ClientClass, because I18n is loaded only once, when other Ruby classes are evaluated; so, this must remain at instance level.
    def js_translate_properties
      @js_translate_properties ||= self.class.netzke_ancestors.inject({}) do |r,klass|
        hsh = klass.js_config.translated_properties.inject({}) { |h,t| h.merge(t => I18n.t("#{klass.i18n_id}.#{t}")) }
        r.merge(hsh)
      end
    end
  end
end
