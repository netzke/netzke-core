require "netzke/javascript/scopes"
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
  # TODO: clean-up, update rdoc
  module Javascript
    extend ActiveSupport::Concern

    included do
      include Scopes
    end

    module ClassMethods

      # Configures JS class
      # Example:
      #   js_configure do |c|
      #     # c is an instance of JsClassConfig
      #     c.title = "My title"
      #     c.mixin
      #     c.include :extra_js
      #     # ...etc
      #   end
      def js_configure &block
        block.call(js_config)
      end

      def js_config
        @_js_config ||= Netzke::Core::JavascriptClassConfig.new(self)
      end

      # Builds this component's xtype
      # E.g.: netzkebasepackwindow, netzkebasepackgridpanel
      def js_xtype
        name.gsub("::", "").downcase
      end

      # Alias prefix. Overridden for plugins.
      def js_alias_prefix
        "widget"
      end

      # Builds this component's alias
      # E.g.: netzke.basepack.window, netzke.basepack.gridpanel
      #
      # MAV from http://stackoverflow.com/questions/5380770/replacing-ext-reg-xtype-in-extjs4
      # "When you use an xtype in Ext JS 4 it looks for a class with an alias of 'widget.[xtype]'"
      def js_alias
        [js_alias_prefix, js_xtype].join(".")
      end

      # Component's JavaScript class declaration.
      # It gets stored in the JS class cache storage (Netzke.classes) at the client side to be reused at the moment of component instantiation.
      def js_class
        res = []
        # Defining the scope if it isn't known yet
        res << %{Ext.ns("#{js_full_scope}");} unless js_full_scope == js_default_scope

        res << (extends_netzke_component? ? js_class_declaration_extending_component : js_class_declaration_new_component)

        # Store created class xtype in the cache
        res << %(
Netzke.cache.push('#{js_xtype}');
)

        res.join("\n")
      end


      # Returns all included JavaScript files as a string
      def js_included
        res = ""

        # Prevent re-including code that was already included by the parent
        # (thus, only include those JS files when include_js was defined in the current class, not in its ancestors)
        ((singleton_methods(false).map(&:to_sym).include?(:include_js) ? include_js : []) + js_config.included_files).each do |path|
          f = File.new(path)
          res << f.read << "\n"
        end

        res
      end

      # JavaScript code needed for this particulaer class. Includes external JS code and the JS class definition for self.
      def js_code
        [js_included, js_class].join("\n")
      end

    protected

      # JS properties and methods merged together
      def js_extend_properties
        # @js_extend_properties ||= js_properties.merge(js_methods)
        js_config.properties
      end

      # Generates declaration of the JS class as direct extension of a Ext component
      def js_class_declaration_new_component
        mixins = js_config.mixins.empty? ? "" : %(#{js_config.mixins.join(", \n")}, )

        # Resulting JS:
%(Ext.define('#{js_full_class_name}', Netzke.chainApply({
alias: '#{js_alias}',
constructor: function(config) {
  Netzke.aliasMethodChain(this, "initComponent", "netzke");
  #{js_full_class_name}.superclass.constructor.call(this, config);
}
}, Netzke.componentMixin,\n#{mixins} #{js_extend_properties.to_nifty_json}));)
      end

      # Generates declaration of the JS class as extension of another Netzke component
      def js_class_declaration_extending_component
        base_class = superclass.js_full_class_name

        mixins = js_config.mixins.empty? ? "" : %(#{js_config.mixins.join(", \n")}, )

        # Resulting JS:
%(Ext.define('#{js_full_class_name}', Netzke.chainApply(#{mixins}#{js_extend_properties.to_nifty_json}, {
extend: '#{base_class}',
alias: '#{js_alias}'
}));)
      end

      def expand_js_include_path(sym, callr) # :nodoc:
        %Q(#{callr.split(".rb:").first}/javascripts/#{sym}.js)
      end

      def extends_netzke_component? # :nodoc:
        superclass != Netzke::Base
      end

    end

    def js_items
      config.items || items
    end

    # The result of this method (a hash) is converted to a JSON object and passed as options to the constructor of our JavaScript class. Override it when you want to pass any extra configuration to the JavaScript side.
    def js_config
      {}.tap do |res|
        # Unique id of the component
        res[:id] = global_id

        # Non-lazy-loaded components
        comp_hash = {}
        eager_loaded_components.each_pair do |comp_name, comp_config|
          comp_instance = component_instance(comp_name.to_sym)
          comp_instance.before_load
          comp_hash[comp_name] = comp_instance.js_config
        end

        # Configuration for all of our non-lazy-loaded children specified here. We can refer to them in +items+ so they get instantiated by Ext.
        res[:netzke_components] = comp_hash unless comp_hash.empty?

        # Endpoints (besides the default "deliver_component" - JavaScript side already knows about it)
        endpoints = self.class.endpoints.keys - [:deliver_component]

        # pass them as strings, not as symbols
        res[:endpoints] = endpoints.map(&:to_s) unless endpoints.empty?

        # Inform the JavaScript side if persistent_config is enabled
        # res[:persistent_config] = persistence_enabled?

        # Include our xtype
        res[:xtype] = self.class.js_xtype

        # Include our alias: Ext.createByAlias may be used to instantiate the component.
        res[:alias] = self.class.js_alias

        # Merge with the rest of config options, besides those that are only meant for the server side
        res.merge!(config.reject{ |k,v| self.class.server_side_config_options.include?(k.to_sym) })

        # Items (nested Ext/Netzke components)
        res[:items] = js_items unless js_items.blank?

        # So we can use getComponent(<component_name>) to retrieve a child component
        res[:item_id] ||= name

        res[:i18n] = js_translate_properties if js_translate_properties.present?

        res[:netzke_plugins] = plugins.map{ |p| p.to_s.camelcase(:lower) } if plugins.present?

        # we need to pass them as strigs, not as symbols
        res[:tools] = res[:tools].map(&:to_s) if res[:tools].present?
      end
    end

    # All the JS-code required by this instance of the component to be instantiated in the browser.
    # It includes JS-classes for the parents, non-lazy-loaded child components, and itself.
    def js_missing_code(cached = [])
      code = dependency_classes.inject("") do |r,k|
        cached.include?(k.js_xtype) ? r : r + k.js_code#.strip_js_comments
      end
      code.blank? ? nil : code
    end

  private

    # Merges all the translations in the class hierarchy
    # TODO: move to JsClassConfig
    def js_translate_properties
      @js_translate_properties ||= self.class.class_ancestors.inject({}) do |r,klass|
        hsh = klass.js_config.translated_properties.inject({}) { |h,t| h.merge(t => I18n.t("#{klass.i18n_id}.#{t}")) }
        r.merge(hsh)
      end
    end

  end
end
