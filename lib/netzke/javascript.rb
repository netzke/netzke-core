module Netzke
  # == Component javascript code
  # Here's a brief explanation on how a javascript class for a component gets built.
  # Component gets defined as a constructor (a function) by +js_class+ class method (see "Inside component's contstructor").
  # +Ext.extend+ provides inheritance from an Ext class specified in +js_base_class+ class method.
  #
  # == Inside component's constructor
  # * Component's constructor gets called with a parameter that is a configuration object provided by +config+ instance method. This configuration is specific for the instance of the component, and, for example, contains this component's unique id. As another example, by means of this configuration object, a grid receives the configuration array for its columns, a form - for its fields, etc.
  module Javascript
    extend ActiveSupport::Concern

    included do
      class_attribute :js_included_files
      self.js_included_files = []
    end

    module ClassMethods

      # The JS (Ext) class that we inherit from on the JS level
      def js_base_class(class_name = nil)
        class_name.nil? ? (read_inheritable_attribute(:js_base_class) || "Ext.Panel") : write_inheritable_attribute(:js_base_class, class_name)
      end

      # Definition of a public JS method, e.g.:
      #     js_method :on_call_server, <<-JS
      #       function(){
      #         this.whatsUp();
      #       }
      #     JS
      def js_method(name, definition = nil)
        definition = yield.l if block_given?
        current_js_methods = read_clean_inheritable_hash(:js_methods)
        current_js_methods.merge!(name => definition.l)
        write_inheritable_attribute(:js_methods, current_js_methods)
      end

      # Returns all JS method definitions in a hash
      def js_methods
        read_clean_inheritable_hash(:js_methods)
      end

      # Definition of JS files which will be dynamically loaded together with this component, e.g.:
      #     js_include "#{File.dirname(__FILE__)}/my_component/static.js"
      # or
      #     js_include "#{File.dirname(__FILE__)}/my_component/one.js","#{File.dirname(__FILE__)}/my_component/two.js"
      # This is alternative to defining self.include_js
      def js_include(*args)
        self.js_included_files += args
      end

      # Definition of a public JS property, e.g.:
      #     js_property :title, "My Netzke Component"
      def js_property(name, value = nil)
        name = name.to_sym
        if value.nil?
          (read_inheritable_attribute(:js_properties) || {})[name]
        else
          current_js_properties = read_clean_inheritable_hash(:js_properties)
          current_js_properties[name] = value
          write_inheritable_attribute(:js_properties, current_js_properties)
        end
      end

      # Assignment of multiple public JS properties in a bunch, e.g.:
      #     js_properties :title => "My Component", :border => true, :html => "Inner HTML"
      def js_properties(hsh = nil)
        if hsh.nil?
          read_clean_inheritable_hash(:js_properties)
        else
          current_js_properties = read_clean_inheritable_hash(:js_properties)
          current_js_properties.merge!(hsh)
          write_inheritable_attribute(:js_properties, current_js_properties)
        end
      end

      # JS properties and methods merged together
      def js_extend_properties
        @_js_extend_properties ||= js_properties.merge(js_methods)
          # res = js_properties.merge(js_methods)
          # extracted_actions = extract_actions(res)
          # res.merge!(:actions => extracted_actions) if !extracted_actions.empty?
          # res
        # end
      end

      # TODO: the code below needs refactoring and cleaning-up

      # component's menus
      # def js_menus; []; end

      # Given class name, e.g. GridPanelLib::Components::RecordFormWindow,
      # returns its scope: "Components.RecordFormWindow"
      def js_class_name_to_scope(name)
        name.split("::")[0..-2].join(".")
      end

      # Top level scope which will be used to scope out Netzke classes
      def js_default_scope
        "Netzke.classes"
      end

      # Scope of this component without default scope
      # e.g.: GridPanelLib.Components
      def js_scope
        js_class_name_to_scope(short_component_class_name)
      end

      # Returns the scope of this component
      # e.g. "Netzke.classes.GridPanelLib"
      def js_full_scope
        js_scope.empty? ? js_default_scope : [js_default_scope, js_scope].join(".")
      end

      # Returns the full name of the JavaScript class, including the scopes *and* the common scope, which is
      # Netzke.classes.
      # E.g.: "Netzke.classes.Netzke.GridPanelLib.RecordFormWindow"
      def js_full_class_name
        [js_full_scope, short_component_class_name.split("::").last].join(".")
      end

      # Builds this component's xtype
      # E.g.: netzkewindow, netzkegridpanel
      def js_xtype
        name.gsub("::", "").downcase
      end

      # are we using JS inheritance? for now, if js_base_class is a Netzke class - yes
      def extends_netzke_component?
        superclass != Netzke::Base
      end

      # Declaration of component's class (stored in the cache storage (Ext.netzke.cache) at the client side
      # to be reused at the moment of component instantiation)
      def js_class(cached = [])
        res = []
        # Defining the scope if it isn't known yet
        res << %{Ext.ns("#{js_full_scope}");} unless js_full_scope == js_default_scope

        res << (extends_netzke_component? ? js_class_declaration_extending_component : js_class_declaration_new_component)

        res << %(Ext.reg("#{js_xtype}", #{js_full_class_name});)

        res.join("\n")
      end


      def js_extra_code
        ""
      end

      # Generates declaration of the JS class as direct extension of a Ext component
      def js_class_declaration_new_component
        %(#{js_full_class_name} = Ext.extend(#{js_base_class}, Ext.apply(Netzke.componentMixin(#{js_base_class}),
#{js_extend_properties.to_nifty_json}));)
      end

      # Generates declaration of the JS class as extension of another Netzke component
      def js_class_declaration_extending_component
        base_class = superclass.js_full_class_name

        # Do we specify our own extend properties?
        # If so, include them, if not - don't re-include those from the parent.
        js_extend_properties.empty? ? \
        %{#{js_full_class_name} = #{base_class};} :
        %{#{js_full_class_name} = Ext.extend(#{base_class}, #{js_extend_properties.to_nifty_json});}
      end

      # Returns all extra JavaScript-code (as string) required by this component's class
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

      def include_js
        []
      end

      # JavaScript code needed for this particulaer class. Includes external JS code and the JS class definition for self.
      def js_code(cached = [])
        [js_included, js_class(cached)].join("\n")
      end

      # Little helper
      def this; "this".l; end

      # Little helper
      def null; "null".l; end

    end

    module InstanceMethods
      # Config that is used for instantiating the component in javascript
      def js_config
        res = {}

        # Unique id of the component
        res.merge!(:id => global_id)

        # Non-late components
        comp_hash = {}
        non_late_components.each_pair do |comp_name, comp_config|
          comp_instance = component_instance(comp_name.to_sym)
          comp_instance.before_load
          comp_hash[comp_name] = comp_instance.js_config
        end

        # All our non-lazy-loaded children are specified here, while in +items+ we barely reference them, because
        # +items+, generally, only contain a subset of all non-lazy-loaded children.
        res[:components] = comp_hash unless comp_hash.empty?

        # Api (besides the default "deliver_component" - JavaScript side already knows about it)
        endpoints = self.class.endpoints - [:deliver_component]
        res.merge!(:endpoints => endpoints) unless endpoints.empty?

        # Inform the JavaScript side if persistent_config is enabled
        # res[:persistent_config] = persistence_enabled?

        # Include our xtype
        res[:xtype] = self.class.js_xtype

        # Merge with the rest of config options, besides those that are only meant for the server side
        res.merge!(config.reject{ |k,v| self.class.server_side_config_options.include?(k.to_sym) })

        if config[:ext_config].present?
          ::ActiveSupport::Deprecation.warn("Using ext_config option is deprecated. All config options must be specified at the same level in the hash.", caller)
          res.merge!(config[:ext_config])
        end

        res[:items] = items unless items.blank?

        res
      end
      
      # Helper to access config[:ext_config] - DEPRECATED
      def ext_config
        ::ActiveSupport::Deprecation.warn("Using ext_config is deprecated. All config options must be specified at the same level in the hash.", caller)
        config[:ext_config] || {}
      end

      # All the JS-code required by this instance of the component to be instantiated in the browser.
      # It includes JS-classes for the parents, non-lazy-loaded child components, and itself.
      def js_missing_code(cached = [])
        code = dependency_classes.inject("") do |r,k|
          cached.include?(k.to_s) ? r : r + k.js_code(cached)#.strip_js_comments
        end
        code.blank? ? nil : code
      end

    end
  end
end