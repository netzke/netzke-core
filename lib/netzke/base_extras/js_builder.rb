module Netzke
  module BaseExtras
    # 
    # Module which provides JS-class generation functionality for the widgets ("client-side"). This code is executed only once per widget class, and the results are cached at the server (unless widget specifies config[:no_caching] => true).
    # Included into Netzke::Base class
    # Most of the methods below are meant to be overwritten by a concrete widget class.
    # 
    module JsBuilder
      def self.included(base)
        base.extend ClassMethods
      end

      #
      # Instance methods
      #

      # The config that is sent from the server and is used for instantiating a widget
      def js_config
        res = {}
    
        # recursively include configs of all (non-late) aggregatees, so that the widget can instantiate them
        aggregatees.each_pair do |aggr_name, aggr_config|
          next if aggr_config[:late_aggregation]
          res["#{aggr_name}_config".to_sym] = aggregatee_instance(aggr_name.to_sym).js_config
        end
    
        # interface
        interface = self.class.interface_points.inject({}){|h,interfacep| h.merge(interfacep => widget_action(interfacep))}
        res.merge!(:interface => interface)
    
        res.merge!(:widget_class_name => short_widget_class_name)

        res.merge!(js_ext_config)
        res.merge!(:id => @id_name)
    
        # include tools and actions
        res.merge!(:tools   => tools)   if tools
        res.merge!(:actions => actions) if actions
        res.merge!(:bbar    => tbar)    if tbar
        res.merge!(:tbar    => bbar)    if bbar

        # include permissions
        res.merge!(:permissions => permissions) unless available_permissions.empty?
      
        res
      end
   
      def js_ext_config
        config[:ext_config] || {}
      end
    
      #
      # The following methods are used when a widget is generated stand-alone (as a part of a HTML page)
      #

      # instantiating
      def js_widget_instance
        %Q{var #{config[:name].to_js} = new Ext.componentCache['#{short_widget_class_name}'](#{js_config.to_js});}
      end

      # rendering
      def js_widget_render
        %Q{#{config[:name].to_js}.render("#{config[:name].to_s.split('_').join('-')}");}
      end

      # container for rendering
      def js_widget_html
        %Q{<div id="#{config[:name].to_s.split('_').join('-')}"></div>}
      end

      #
      #
      #

      # All the JS-code required by this *instance* of the widget. It includes the JS-class for the widget
      # itself, as well as JS-classes for all widgets (non-late) aggregatees.
      def js_missing_code(cached_dependencies = [])
        result = ""
        dependencies.each do |dep_name|
          unless cached_dependencies.include?(dep_name)
            dependency_class = "Netzke::#{dep_name}".constantize
            result << dependency_class.js_class
          end
        end
        result
      end
   
      # widget's actions, tools and toolbars that are loaded at the moment of instantiating a widget
      def actions; nil; end
      def tools; nil; end
      def tbar; nil; end
      def bbar; nil; end

      # little helpers
      def this; "this".l; end
      def null; "null".l; end


      # Methods used to create the javascript class (only once per widget class). 
      # The generated code gets cached at the browser, and the widget intstances (at the browser side)
      # get instantiated from it.
      # All these methods can be overwritten in case you want to extend the functionality of some pre-built widget
      # instead of using it as is (using both would cause JS-code duplication)
      module ClassMethods
        # the JS (Ext) class that we inherit from on JS-level
        def js_base_class; "Ext.Panel"; end

        # functions and properties that will be used to extend the functionality of (Ext) JS-class specified in js_base_class
        def js_extend_properties; {}; end
    
        # code executed before and after the constructor
        def js_before_constructor; ""; end
        def js_after_constructor; ""; end

        # widget's listeners
        def js_listeners; {}; end
    
        # widget's menus
        def js_menus; []; end
    
        # items
        def js_items; null; end

        # default config that is always passed into the constructor
        def js_default_config
          {
            :title     => "config.id.humanize()".l,
            :listeners => js_listeners,
            :tools     => "config.tools".l,
            :actions   => "config.actions".l,
            :tbar      => "config.tbar".l,
            :bbar      => "config.bbar".l,
            # :items   => "config.items".l,
            # :items   => js_items,
            :height    => 400,
            :width     => 800,
            :border    => false
          }
        end

        # Declaration of widget's class (stored in the cache storage (Ext.componentCache) at the client side 
        # to be reused at the moment of widget instantiation)
        def js_class
          <<-JS
          Ext.componentCache['#{short_widget_class_name}'] = Ext.extend(#{js_base_class}, Ext.chainApply([Ext.widgetMixIn, {
            constructor: function(config){
              this.widgetInit(config);
              #{js_before_constructor}
              Ext.componentCache['#{short_widget_class_name}'].superclass.constructor.call(this, Ext.apply(#{js_default_config.to_js}, config));
              #{js_after_constructor}
              this.setEvents();
              this.addMenus(#{js_menus.to_js});
            }
          }, #{js_extend_properties.to_js}]))
          JS
        end

        # class definition of the widget plus that of all the dependencies, minus those that are specified as cached_dependencies
        def js_missing_code(cached_dependencies = [])
          result = ""
          dependencies.each do |dep_name|
            dependency_class = "Netzke::#{dep_name}".constantize
            result << dependency_class.js_class_code(cached_dependencies)
          end
          result << js_class.strip_js_comments unless cached_dependencies.include?(short_widget_class_name) && !config[:no_caching]
          result
        end
      
        def this; "this".l; end
        def null; "null".l; end
      
      end
   
    end
  end
end