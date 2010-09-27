module Netzke
  module Component
    # == Component javascript code
    # Here's a brief explanation on how a javascript class for a component gets built.
    # Component gets defined as a constructor (a function) by +js_class+ class method (see "Inside component's contstructor").
    # +Ext.extend+ provides inheritance from an Ext class specified in +js_base_class+ class method.
    # 
    # == Inside component's constructor
    # * Component's constructor gets called with a parameter that is a configuration object provided by +js_config+ instance method. This configuration is specific for the instance of the component, and, for example, contains this component's unique id. As another example, by means of this configuration object, a grid receives the configuration array for its columns, a form - for its fields, etc. With other words, everything that may change from instance to instance of the same component's class, goes in here.
    #
    module Javascript
      module ClassMethods

        # the JS (Ext) class that we inherit from on JS-level
        def js_base_class(class_name = nil)
          class_name.nil? ? (read_inheritable_attribute(:js_base_class) || "Ext.Panel") : write_inheritable_attribute(:js_base_class, class_name)
        end
        
        def js_method(name, definition = nil)
          definition = yield.l if block_given?
          current_js_methods = read_inheritable_attribute(:js_methods) || {}
          # we don't want here any js_methods from the superclass
          current_js_methods = {} if self.superclass.singleton_methods.map(&:to_sym).include?(:js_methods) && current_js_methods == superclass.js_methods
          current_js_methods.merge!(name => definition.l) if definition
          write_inheritable_attribute(:js_methods, current_js_methods)
        end
        
        def js_methods
          res = read_inheritable_attribute(:js_methods) || {}
          res = {} if res == superclass.read_inheritable_attribute(:js_methods)
          res
        end

        # Properties that will be used to extend the functionality of (Ext) JS-class specified in js_base_class
        def js_properties(hsh = nil)
          if hsh.nil? 
            res = read_inheritable_attribute(:js_properties) || {}
            res = {} if res == superclass.read_inheritable_attribute(:js_properties)
            res
          else
            current_js_properties = read_inheritable_attribute(:js_properties) || {}
            # we don't want here any js_properties from the superclass
            current_js_properties = {} if self.superclass.singleton_methods.map(&:to_sym).include?(:js_properties) && current_js_properties == self.superclass.js_properties
            current_js_properties.merge!(hsh)
            write_inheritable_attribute(:js_properties, current_js_properties)
          end
        end

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

        # Returns the name of the JavaScript class for this component, including the scope
        # e.g.: "GridPanelLib.RecordFormWindow"
        def js_scoped_class_name
          short_component_class_name.gsub("::", ".")
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
          superclass != Netzke::Component::Base
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
        
        # Combined properties and methods
        def js_extend_properties
          @_js_extend_properties ||= begin
            res = js_properties.merge(js_methods)
            extracted_actions = extract_actions(res)
            res.merge!(:actions => extracted_actions) if !extracted_actions.empty?
            res
          end
        end
        
        def js_extra_code
          ""
        end
        
        # Generates declaration of the JS class as direct extension of a Ext component
        def js_class_declaration_new_component
          %(#{js_full_class_name} = Ext.extend(#{js_base_class}, Ext.apply(Ext.componentMixIn(#{js_base_class}),
#{js_extend_properties.to_nifty_json}));)
        end
        
        # Generates declaration of the JS class as extension of another Netzke component
        def js_class_declaration_extending_component
          # Do we have js_base_class defined? If so, use it instead of the js_full_class_name of the superclass
          # js_class = singleton_methods(false).include?(:js_base_class) ? js_base_class : superclass.js_full_class_name
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
          singleton_methods(false).include?(:include_js) && include_js.each do |path|
            f = File.new(path)
            res << f.read << "\n"
          end

          res
        end

        def include_js
          []
        end

        # All JavaScript code needed for this class, including one from the ancestor component
        def js_code(cached = [])
          res = ""

          # include the base-class javascript if doing JS inheritance
          if extends_netzke_component? && !cached.include?(superclass.short_component_class_name)
            res << superclass.js_code(cached) << "\n"
          end

          # include static javascripts
          res << js_included << "\n"

          # our own JS class definition
          res << js_class(cached)
          res
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
          aggr_hash = {}
          
          non_late_components.each_pair do |aggr_name, aggr_config|
            aggr_instance = component_instance(aggr_name.to_sym)
            aggr_instance.before_load
            aggr_hash[aggr_name] = aggr_instance.js_config
          end
          
          res[:components] = aggr_hash unless aggr_hash.empty?

          # Api (besides the default "load_component_with_cache" - JavaScript side already knows about it)
          endpoints = self.class.endpoints - [:load_component_with_cache]
          res.merge!(:netzke_api => endpoints) unless endpoints.empty?

          # Component class name. Needed for dynamic instantiation in javascript.
          res.merge!(:scoped_class_name => self.class.js_scoped_class_name)

          # Inform the JavaScript side if persistent_config is enabled
          # res[:persistent_config] = persistent_config_enabled?

          # Include our xtype
          res[:xtype] = self.class.js_xtype

          # Merge with the rest of config options, besides those that are only meant for the server side
          res.merge!(config.reject{ |k,v| self.class.server_side_config_options.include?(k.to_sym) })
          
          res[:items] = @js_items
          
          res
        end

        # All the JS-code required by this instance of the component to be instantiated in the browser.
        # It includes the JS-class for the component itself, as well as JS-classes for all components' (non-late) components.
        def js_missing_code(cached = [])
          code = dependency_classes.inject("") do |r,k| 
            cached.include?(k) ? r : r + "Netzke::#{k}".constantize.js_code(cached)#.strip_js_comments
          end
          code.blank? ? nil : code
        end
        
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        # receiver.ext_class "Ext.Panel"
        
        # Overriding Ext.Component#initComponent in core.js
        # receiver.js_alias_method_chain :init_component, :netzke
      end
    end
  end
end
