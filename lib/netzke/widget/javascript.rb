module Netzke
  module Widget
    module Javascript
      module ClassMethods
        # the JS (Ext) class that we inherit from on JS-level
        def js_base_class
          "Ext.Panel"
        end

        # Properties (including methods) that will be used to extend the functionality of (Ext) JS-class specified in js_base_class
        def js_extend_properties 
          {}
        end

        # widget's menus
        def js_menus; []; end

        # Given class name, e.g. GridPanelLib::Widgets::RecordFormWindow, 
        # returns its scope: "Widgets.RecordFormWindow"
        def js_class_name_to_scope(name)
          name.split("::")[0..-2].join(".")
        end

        # Top level scope which will be used to scope out Netzke classes
        def js_default_scope
          "Netzke.classes"
        end

        # Scope of this widget without default scope
        # e.g.: GridPanelLib.Widgets
        def js_scope
          js_class_name_to_scope(short_widget_class_name)
        end

        # Returns the scope of this widget
        # e.g. "Netzke.classes.GridPanelLib"
        def js_full_scope
          js_scope.empty? ? js_default_scope : [js_default_scope, js_scope].join(".")
        end

        # Returns the name of the JavaScript class for this widget, including the scope
        # e.g.: "GridPanelLib.RecordFormWindow"
        def js_scoped_class_name
          short_widget_class_name.gsub("::", ".")
        end

        # Returns the full name of the JavaScript class, including the scopes *and* the common scope, which is
        # Netzke.classes.
        # E.g.: "Netzke.classes.Netzke.GridPanelLib.RecordFormWindow"
        def js_full_class_name
          [js_full_scope, short_widget_class_name.split("::").last].join(".")
        end

        # Builds this widget's xtype
        # E.g.: netzkewindow, netzkegridpanel
        def js_xtype
          name.gsub("::", "").downcase
        end

        # are we using JS inheritance? for now, if js_base_class is a Netzke class - yes
        def js_inheritance?
          superclass != Netzke::Widget::Base
        end

        # Declaration of widget's class (stored in the cache storage (Ext.netzke.cache) at the client side 
        # to be reused at the moment of widget instantiation)
        def js_class(cached = [])
          # Defining the scope if it isn't known yet
          # res = %Q{
          #   if (!#{js_full_scope}) {
          #     Ext.ns("#{js_full_scope}");
          #   }
          # }

          res = ""

          if js_inheritance?
            # Using javascript inheritance
            res << <<-END_OF_JAVASCRIPT
            // Costructor
  #{js_full_class_name} = function(config){
    #{js_full_class_name}.superclass.constructor.call(this, config);
  };
            END_OF_JAVASCRIPT

            # Do we specify our own extend properties (overriding js_extend_properties)? 
            # If so, include them, if not - don't re-include those from the parent.
            res << (singleton_methods(false).include?(:js_extend_properties) ? %Q{
  Ext.extend(#{js_full_class_name}, #{superclass.js_full_class_name}, #{js_extend_properties.to_nifty_json});
            } : %Q{
  Ext.extend(#{js_full_class_name}, #{superclass.js_full_class_name});
            })

            res << <<-END_OF_JAVASCRIPT
            // Register our xtype
            Ext.reg("#{js_xtype}", #{js_full_class_name});
            END_OF_JAVASCRIPT

          else
            res << <<-END_OF_JAVASCRIPT
            // Constructor
            #{js_full_class_name} = function(config){
              // Do all the initializations that every Netzke widget should do: create methods for API-points,
              // process actions, tools, toolbars
              this.commonBeforeConstructor(config);
              // Call the constructor of the inherited class
              #{js_full_class_name}.superclass.constructor.call(this, config);
              // What every widget should do after calling the constructor of the inherited class, like
              // setting extra events
              this.commonAfterConstructor(config);
            };
            Ext.extend(#{js_full_class_name}, #{js_base_class}, Ext.applyIf(#{js_extend_properties.to_nifty_json}, Ext.widgetMixIn));
            // Register xtype
            Ext.reg("#{js_xtype}", #{js_full_class_name});
            END_OF_JAVASCRIPT
          end

          res
        end
        
        # Returns all extra JavaScript-code (as string) required by this widget's class
        def js_included
          res = ""

          # Prevent re-including code that was already included by the parent
          singleton_methods(false).include?("include_js") && include_js.each do |path|
            f = File.new(path)
            res << f.read << "\n"
          end

          res
        end

        # All JavaScript code needed for this class, including one from the ancestor widget
        def js_code(cached = [])
          res = ""

          # include the base-class javascript if doing JS inheritance
          if js_inheritance? && !cached.include?(superclass.short_widget_class_name)
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
        # Config that is used for instantiating the widget in javascript
        def js_config
          res = {}

          # Unique id of the widget
          res.merge!(:id => global_id)

          # Recursively include configs of all non-late aggregatees, so that the widget can instantiate them
          # in javascript immediately.
          non_late_aggregatees.each_pair do |aggr_name, aggr_config|
            aggr_instance = aggregatee_instance(aggr_name.to_sym)
            aggr_instance.before_load
            res[:"#{aggr_name}_config"] = aggr_instance.js_config
          end

          # Api (besides the default "load_aggregatee_with_cache" - JavaScript side already knows about it)
          api_points = self.class.api_points.reject{ |p| p == :load_aggregatee_with_cache }
          res.merge!(:netzke_api => api_points) unless api_points.empty?

          # Widget class name. Needed for dynamic instantiation in javascript.
          res.merge!(:scoped_class_name => self.class.js_scoped_class_name)

          # Actions, toolbars and menus
          # tools   && res.merge!(:tools   => tools)
          # actions && res.merge!(:actions => actions)
          # menu    && res.merge!(:menu    => menu)

          # Inform the JavaScript side if persistent_config is enabled
          res[:persistent_config] = persistent_config_enabled?

          # Merge with all config options passed as hash to config[:ext_config]
          res.merge!(ext_config)

          res
        end

        # All the JS-code required by this instance of the widget to be instantiated in the browser.
        # It includes the JS-class for the widget itself, as well as JS-classes for all widgets' (non-late) aggregatees.
        def js_missing_code(cached = [])
          code = dependency_classes.inject("") do |r,k| 
            cached.include?(k) ? r : r + "Netzke::#{k}".constantize.js_code(cached).strip_js_comments
          end
          code.blank? ? nil : code
        end
        
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end