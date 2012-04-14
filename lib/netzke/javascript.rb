require "netzke/javascript/scopes"
module Netzke
  # == Component's JavaScript class generation
  # Each component operates on both client and server side. At the server side it's represented by a Ruby class, at the client side it's represented by a corresponding JavaScript class (extending one of the Ext JS classes, specified by Netzke::Base.js_base_class, or, in case of extending an existing Netzke component, that component's JavaScript class).
  #
  # The following public JavaScript methods are defined on all Netzke components
  # *
  #
  # Here's a brief explanation on how a javascript class for a component gets built.
  # Component gets defined as a constructor (a function) by +js_class+ class method (see "Inside component's contstructor").
  # +Ext.extend+ provides inheritance from an Ext class specified in +js_base_class+ class method.
  #
  # == Inside component's constructor
  # * Component's constructor gets called with a parameter that is a configuration object provided by +config+ instance method. This configuration is specific for the instance of the component, and, for example, contains this component's unique id. As another example, by means of this configuration object, a grid receives the configuration array for its columns, a form - for its fields, etc.
  module Javascript
    extend ActiveSupport::Concern

    included do
      include Scopes

      class_attribute :js_included_files
      self.js_included_files = []

      # Returns all JS method definitions in a hash
      class_attribute :js_methods_attr
      self.js_methods_attr = {}

      class_attribute :js_properties_attr
      self.js_properties_attr = {}

      # Returns all objects to be mixed in (as array of strings)
      class_attribute :js_mixins_attr
      self.js_mixins_attr = []

      class_attribute :js_translated_properties_attr
      self.js_translated_properties_attr = {}

      class_attribute :js_base_class_attr
      self.js_base_class_attr = 'Ext.panel.Panel'
    end

    module ClassMethods

      # Used it to specify what JavaScript class this component's JavaScript class will be extending, e.g.:
      #
      #     js_base_class "Ext.TabPanel"
      #
      # By default, "Ext.Panel" is assumed.
      #
      # If called without parameters, returns the JS base class declared for the component.
      def js_base_class(class_name = nil)
        class_name.nil? ? self.js_base_class_attr : self.js_base_class_attr = class_name
      end

      # Use it to define a public method of the component's JavaScript class, e.g.:
      #
      #     js_method :do_something, <<-JS
      #       function(params){
      #         // implementation, maybe dynamically generated
      #       }
      #     JS
      #
      # This will effectively result in definition of a public method called +doSomething+ in the JavaScript class (note the conversion from underscore_name to camelCaseName).
      def js_method(name, definition = nil)
        definition = yield.l if block_given?
        current_js_methods = clean_class_attribute_hash(:js_methods_attr).dup
        self.js_methods_attr = current_js_methods.merge(name => definition.l)
      end

      # Returns all JS method definitions in a hash
      def js_methods
        clean_class_attribute_hash(:js_methods_attr)
      end

      # Use it to specify JS files to be loaded before this component's JS code. Useful when using external extensions required by this component.
      # It may accept one or more symbols or strings. Strings will be interpreted as full paths to included JS file:
      #
      #     js_include "#{File.dirname(__FILE__)}/my_component/one.js","#{File.dirname(__FILE__)}/my_component/two.js"
      #
      # Symbols will be expanded following a convention, e.g.:
      #
      #     class MyComponent < Netzke::Base
      #       js_include :some_library
      #       # ...
      #     end
      #
      # This will "include" a JavaScript file +{component_location}/my_component/javascripts/some_library.js+
      def js_include(*args)
        callr = caller.first

        self.js_included_files |= args.map{ |a| a.is_a?(Symbol) ? expand_js_include_path(a, callr) : a }
      end

      # Used to define default properties of the JavaScript class, e.g.:
      #
      #     js_properties :collapsible => true, :hide_collapse_tool => true
      #
      # (this will result in the definition of the following properties in the JavaScript class's prototype: +collapsible+ and +hideCollapseTool+ (note the automatic conversion from underscore to camelcase))
      #
      # Also, +js_property+ can be used to define properties one by one.
      #
      # For the complete list of available options refer to the Ext documentation, the "Config Options" section of a the component specified with +js_base_class+.
      # Note, that not all the configuration options can be defined on the prototype of the class. For example, defining +items+ on the prototype won't take any effect, so, +items+ should be passed as a configuration option at the moment of instantiation (see Netzke::Base#configuration and Netzke::Base#default_config).
      def js_properties(hsh = nil)
        if hsh.nil?
          clean_class_attribute_hash(:js_properties_attr)
        else
          current_js_properties = clean_class_attribute_hash(:js_properties_attr).dup
          self.js_properties_attr = current_js_properties.merge(hsh)
        end
      end

      # Used to define a single JS class property, e.g.:
      #     js_property :title, "My Netzke Component"
      def js_property(name, value = nil)
        name = name.to_sym
        if value.nil?
          clean_class_attribute_hash(:js_properties_attr)[name]
        else
          current_js_properties = clean_class_attribute_hash(:js_properties_attr).dup
          current_js_properties[name] = value
          self.js_properties_attr = current_js_properties
        end
      end

      # Defines the "i18n" config property, that is a translation object for this component, such as:
      #     i18n: {
      #       overwriteConfirm: "Are you sure you want to overwrite preset '{0}'?",
      #       overwriteConfirmTitle: "Overwriting preset",
      #       deleteConfirm: "Are you sure you want to delete preset '{0}'?",
      #       deleteConfirmTitle: "Deleting preset"
      #     }
      #
      # E.g.:
      #     js_translate :overwrite_confirm, :overwrite_confirm_title, :delete_confirm, :delete_confirm_title
      #
      # TODO: make the name of the root property configurable
      def js_translate(*properties)
        if properties.empty?
          clean_class_attribute_hash(:js_translated_properties_attr)
        else
          current_translated_properties = clean_class_attribute_hash(:js_translated_properties_attr).dup
          properties.each do |p|
            if p.is_a?(Hash)
              # TODO: make it possible to nest translated objects
            else
              current_translated_properties[p] = p
            end
          end

          self.js_translated_properties_attr = current_translated_properties
        end
      end

      # Use it to "mixin" JavaScript objects defined in a separate file.
      #
      # You do not _have_ to use +js_method+ or +js_properties+ if those methods or properties are not supposed to be changed _dynamically_ (by means of configuring the component on the class level). Instead, you may "mixin" a JavaScript object defined in the JavaScript file named following a certain convention. This way static JavaScript code will rest in a corresponding .js file, not in the Ruby class. E.g.:
      #
      #     class MyComponent < Netzke::Base
      #       js_mixin :some_functionality
      #       #...
      #     end
      #
      # This will "mixin" a JavaScript object defined in a file called +{component_location}/my_component/javascripts/some_functionality.js+, which way contain something like this:
      #
      #     {
      #       someProperty: 100,
      #
      #       someMethod: function(params){
      #         // ...
      #       }
      #     }
      #
      # Also accepts a string, which will be interpreted as a full path to the file (useful for sharing mixins between classes).
      # With no parameters, will assume :component_class_name_underscored.
      def js_mixin(*args)
        args << name.split("::").last.underscore.to_sym if args.empty? # if no args provided, component_class_underscored_name is assumed
        current_mixins = clean_class_attribute_array(:js_mixins_attr)
        callr = caller.first
        args.each{ |a| current_mixins << (a.is_a?(Symbol) ? File.read(expand_js_include_path(a, callr)) : File.read(a))}
        self.js_mixins_attr = current_mixins
      end

      # Returns all objects to be mixed in (as array of strings)
      def js_mixins
        clean_class_attribute_array(:js_mixins_attr)
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
        ((singleton_methods(false).map(&:to_sym).include?(:include_js) ? include_js : []) + js_included_files).each do |path|
          f = File.new(path)
          res << f.read << "\n"
        end

        res
      end

      # DEPRECATED. Returns an array of included files. Made to be overridden. +js_include+ is preferred way.
      def include_js
        []
      end

      # JavaScript code needed for this particulaer class. Includes external JS code and the JS class definition for self.
      def js_code
        [js_included, js_class].join("\n")
      end

      protected

        # Little helper
        def this; "this".l; end

        # Little helper. E.g.:
        #
        #     js_property :load_mask, null
        def null; "null".l; end

        # JS properties and methods merged together
        def js_extend_properties
          @js_extend_properties ||= js_properties.merge(js_methods)
        end

        # Generates declaration of the JS class as direct extension of a Ext component
        def js_class_declaration_new_component
          mixins = js_mixins.empty? ? "" : %(#{js_mixins.join(", \n")}, )

          # Resulting JS:
%(Ext.define('#{js_full_class_name}', Netzke.chainApply({
  extend: '#{js_base_class}',
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

          mixins = js_mixins.empty? ? "" : %(#{js_mixins.join(", \n")}, )

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

    # The result of this method (a hash) is converted to a JSON object and passed as options
    # to the constructor of our JavaScript class. Override it when you want to pass any extra configuration
    # to the JavaScript side.
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

        if config[:ext_config].present?
          ::ActiveSupport::Deprecation.warn("Using ext_config option is deprecated. All config options must be specified at the same level in the hash.", caller)
          res.merge!(config[:ext_config])
        end

        # Items (nested Ext/Netzke components)
        res[:items] = items unless items.blank?

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

    # DEPRECATED. Helper to access config[:ext_config].
    def ext_config
      ::ActiveSupport::Deprecation.warn("Using ext_config is deprecated. All config options must be specified at the same level in the hash.", caller)
      config[:ext_config] || {}
    end

    private

      # Merges all the translations in the class hierarchy
      def js_translate_properties
        @js_translate_properties ||= self.class.class_ancestors.inject({}) do |r,klass|
          hsh = klass.js_translate.keys.inject({}) { |h,t| h.merge(t => I18n.t("#{klass.i18n_id}.#{t}")) }
          r.merge(hsh)
        end
      end

  end
end
