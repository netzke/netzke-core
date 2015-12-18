module Netzke::Core
  # Client class definition and instantiation.
  #
  # == JavaScript instance methods
  #
  # The following public JavaScript methods are defined on (mixed-in into) all Netzke components (for detailed documentation on them see the inline documentation in javascript/base.js and javascript/ext.js files):
  # * nzLoadComponent - dynamically loads a child Netzke component
  # * nzInstantiateComponent - instantiates and returns a Netzke component by its item_id
  # * nzFeedback - shows a feedback message
  # * nzSessionExpired - gets called when the session that the component is defined in gets expired. Override it to do whatever is appropriate.
  module ClientCode
    extend ActiveSupport::Concern

    module ClassMethods
      # Configures client class
      # Example:
      #
      #   client_class do |c|
      #     # c is an instance of ClientClassConfig
      #     c.title = "My title"
      #     c.require :extra_js
      #     # ...etc
      #   end
      #
      # For more details see {Netzke::Core::ClientClassConfig}
      def client_class &block
        raise ArgumentError, "client_class called without block" unless block_given?
        @configure_blocks ||= []
        @configure_blocks << [block, dir(caller.first)]
      end

      # Class-level client class config.
      # Note: late evaluation of `client_class` blocks allows us using class-level configs in those blocks, e.g.:
      #
      #     class ConfigurableOnClassLevel < Netzke::Base
      #       class_attribute :title
      #       self.title = "Default"
      #       client_class do |c|
      #         c.title = self.title
      #       end
      #     end
      #
      #     ConfigurableOnClassLevel.title = "Overridden"
      def client_class_config
        return @client_class_config if @client_class_config

        @client_class_config = Netzke::Core::ClientClassConfig.new(self, called_from)

        (@configure_blocks || []).each do |block, dir|
          @client_class_config.dir = dir
          block.call(@client_class_config) if block
        end

        @client_class_config
      end

      # Path to the dir with this component/extension's extra code (ruby modules, scripts, stylesheets)
      def dir(cllr)
        %Q(#{cllr.split(".rb:").first})
      end
    end

    # Builds {#js_config} used for instantiating a client class. Override it when you need to extend/modify the config for the JS component intance. It's *not* being called when the *server* class is being instantiated (e.g. to process an endpoint call). With other words, it's only being called before a component is first being loaded in the browser. so, it's ok to do heavy stuf fhere, like building a tree panel nodes from the database.
    def configure_client(c)
      c.merge!(normalized_config)

      %w[id item_id path netzke_components endpoints xtype alias i18n netzke_plugins].each do |thing|
        js_thing = send(:"js_#{thing}")
        c[thing] = js_thing if js_thing.present?
        c.client_config = client_config.netzke_literalize_keys # because this is what we'll get back from client side as server config, and the keys must be snake_case
      end

      # reset component session
      # TODO: also remove empty hashes from the global session
      component_session.clear
    end

    def js_path
      @path
    end

    # Global id in the component tree, following the double-underscore notation, e.g. +books__config_panel__form+
    def js_id
      @js_id ||= parent.nil? ? @item_id : [parent.js_id, @item_id].join("__")
    end

    def js_xtype
      self.class.client_class_config.xtype
    end

    def js_item_id
      @item_id
    end

    # Ext.createByAlias may be used to instantiate the component.
    def js_alias
      self.class.client_class_config.class_alias
    end

    def js_endpoints
      self.class.endpoints.keys.map{ |p| p.to_s.camelcase(:lower) }
    end

    def js_netzke_plugins
      plugins.map{ |p| p.to_s.camelcase(:lower) }
    end

    # Instance-level client class config. The result of this method (a hash) is converted to a JSON object and passed as options to the constructor of our JavaScript class.
    # Not to be overridden, override {#configure_client} instead.
    def js_config
      @js_config ||= ActiveSupport::OrderedOptions.new.tap{|c| configure_client(c)}
    end

    # Hash containing configuration for all child components to be instantiated at the JS side
    def js_components
      @js_components ||= eagerly_loaded_components.inject({}) do |out, name|
        instance = component_instance(name.to_sym)
        out.merge(name => instance.js_config)
      end
    end

    alias js_netzke_components js_components

    # All the JS-code required by this instance of the component to be instantiated in the browser, excluding cached
    # code.
    # It includes JS-classes for the parents, eagerly loaded child components, and itself.
    def js_missing_code(cached = [])
      code = dependency_classes.inject("") do |r,k|
        cached.include?(k.client_class_config.xtype) ? r : r + k.client_class_config.code_with_dependencies
      end
      code.blank? ? nil : Netzke::Core::DynamicAssets.minify_js(code)
    end

    protected

    # Allows referring to client-side function that will be called in the scope of the component. Handy to specify
    # handlers for tools/actions, or any other functions that have to be passed as configuration to different Ext JS
    # components. Usage:
    #
    #   class MyComponent < Netzke::Base
    #     def configure(c)
    #       super
    #       c.bbar = [{text: 'Export', handler: f(:handle_export)}]
    #     end
    #   end
    #
    #   As a result, `MyComponent`'s client-side `handleExport` function will be called in the component's scope, receiving all the
    #   usual handler parameters from Ext JS.
    #   Read more on how to define client-side functions in `Netzke::Core::ClientClassConfig`.
    def f(name)
      Netzke::Core::JsonLiteral.new("function(){var c=Ext.getCmp('#{js_id}'); return c.#{name.to_s.camelize(:lower)}.apply(c, arguments);}")
    end

    private

    # Merges all the translations in the class hierarchy
    # Note: this method can't be moved out to ClientClassConfig, because I18n is loaded only once, when other Ruby classes are evaluated; so, this must remain at instance level.
    def js_i18n
      @js_i18n ||= self.class.netzke_ancestors.inject({}) do |r,klass|
        hsh = klass.client_class_config.translated_properties.inject({}) { |h,t| h.merge(t => I18n.t("#{klass.i18n_id}.#{t}")) }
        r.merge(hsh)
      end
    end
  end
end
