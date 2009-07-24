module Netzke
  module BaseExtras
    # 
    # Module which provides JS-class generation functionality for the widgets ("client-side"). This code is executed only once per widget class, and the results are cached at the server.
    # Included into Netzke::Base class.
    # Most of the methods below are meant to be overwritten.
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
        
        # Unique id of the widget
        res.merge!(:id => id_name)
    
        # Recursively include configs of all non-late aggregatees, so that the widget can instantiate them in
        # in the browser immediately.
        aggregatees.each_pair do |aggr_name, aggr_config|
          next if aggr_config[:late_aggregation] # only non-late aggregatees
          aggr_instance = aggregatee_instance(aggr_name.to_sym)
          aggr_instance.before_load
          res["#{aggr_name}_config".to_sym] = aggr_instance.js_config
        end
    
        # Api
        # api = self.class.api_points.inject({}){|h,apip| h.merge(apip => widget_action(apip))}
        res.merge!(:api => self.class.api_points)
    
        # Widget class name
        res.merge!(:widget_class_name => short_widget_class_name)
        
        # Include
        res.merge!(ext_config)
    
        # Actions, toolbars and menus
        tools   && res.merge!(:tools   => tools)
        actions && res.merge!(:actions => actions)
        # tbar    && res.merge!(:tbar    => tbar)
        # bbar    && res.merge!(:bbar    => bbar)
        menu    && res.merge!(:menu    => menu)

        # Permissions
        res.merge!(:permissions => permissions) unless available_permissions.empty?
      
        res
      end
    
      # All the JS-code required by this instance of the widget to be instantiated in the browser.
      # It includes the JS-class for the widget itself, as well as JS-classes for all widgets' (non-late) aggregatees.
      def js_missing_code(cached_dependencies = [])
        code = dependency_classes.inject("") do |r,k| 
          cached_dependencies.include?(k) ? r : r + "Netzke::#{k}".constantize.js_code(cached_dependencies).strip_js_comments
        end
        code.blank? ? nil : code
      end
      
      def css_missing_code(cached_dependencies = [])
        code = dependency_classes.inject("") do |r,k| 
          cached_dependencies.include?(k) ? r : r + "Netzke::#{k}".constantize.css_code(cached_dependencies)
        end
        code.blank? ? nil : code
      end
    
      #
      # The following methods are used when a widget is generated stand-alone (as a part of a HTML page)
      #

      # instantiating
      def js_widget_instance
        %Q{var #{name.jsonify} = new Ext.netzke.cache.#{short_widget_class_name}(#{js_config.to_nifty_json});}
      end

      # rendering
      def js_widget_render
        %Q{#{name.jsonify}.render("#{name.to_s.split('_').join('-')}");}
      end

      # container for rendering
      def js_widget_html
        %Q{<div id="#{name.to_s.split('_').join('-')}"></div>}
      end

      #
      #
      #
   
      # widget's actions, tools and toolbars that are loaded at the moment of instantiating a widget
      def actions; nil; end
      # def tbar; nil; end
      # def bbar; nil; end
      def menu; nil; end
      def tools; nil; end

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

        # default config that gets merged with Base#js_config
        def js_default_config
          {
            # :header    => user_has_role?(:configurator) ? true : nil,
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
            :border    => false,
            :is_netzke => true # to distinguish a Netzke widget from regular Ext components
          }
        end

        # functions and properties that will be used to extend the functionality of (Ext) JS-class specified in js_base_class
        def js_extend_properties; {
          
        }; end
    
        # code executed before and after the constructor
        def js_before_constructor; ""; end
        def js_after_constructor; ""; end

        # widget's listeners
        def js_listeners; {}; end
    
        # widget's menus
        def js_menus; []; end
    
        # items
        def js_items; null; end
        
        # are we using JS inheritance? for now, if js_base_class is a Netzke class - yes
        def js_inheritance
          js_base_class.is_a?(Class)
        end

        # Declaration of widget's class (stored in the cache storage (Ext.netzke.cache) at the client side 
        # to be reused at the moment of widget instantiation)
        def js_class
          if js_inheritance
<<-JS
Ext.netzke.cache.#{short_widget_class_name} = function(config){
  Ext.netzke.cache.#{short_widget_class_name}.superclass.constructor.call(this, config);
};
Ext.extend(Ext.netzke.cache.#{short_widget_class_name}, Ext.netzke.cache.#{js_base_class.short_widget_class_name}, Ext.applyIf(#{js_extend_properties.to_nifty_json}, Ext.widgetMixIn));

JS
          else
            js_add_menus = "this.addMenus(#{js_menus.to_nifty_json});" unless js_menus.empty?
<<-JS
Ext.netzke.cache.#{short_widget_class_name} = function(config){
    this.commonBeforeConstructor(config);
    #{js_before_constructor}
    Ext.netzke.cache.#{short_widget_class_name}.superclass.constructor.call(this, Ext.apply(#{js_default_config.to_nifty_json}, config));
    this.commonAfterConstructor(config);
    #{js_after_constructor}
    #{js_add_menus}
};
Ext.extend(Ext.netzke.cache.#{short_widget_class_name}, #{js_base_class}, Ext.applyIf(#{js_extend_properties.to_nifty_json}, Ext.widgetMixIn));
JS
          end
        end
        
        #
        # Include extra code from Ext js library (e.g. examples)
        #
        def ext_js_include(*args)
          included_ext_js = read_inheritable_attribute(:included_ext_js) || []
          args.each {|f| included_ext_js << f}
          write_inheritable_attribute(:included_ext_js, included_ext_js)
        end

        #
        # Include extra Javascript code. This code will be loaded along with the widget's class and before it.
        #
        # Example usage:
        # js_include "File.dirname(__FILE__)/form_panel_extras/javascripts/xdatetime.js", 
        #     :ext_examples => ["grid-filtering/menu/EditableItem.js", "grid-filtering/menu/RangeMenu.js"],
        #     "File.dirname(__FILE__)/form_panel_extras/javascripts/xcheckbox.js"
        #
        def js_include(*args)
          included_js = read_inheritable_attribute(:included_js) || []
          args.each do |inclusion|
            if inclusion.is_a?(Hash)
              # we are signalized a non-default file location (e.g. Ext examples)
              case inclusion.keys.first
              when :ext_examples
                location = Netzke::Base.config[:ext_location] + "/examples/"
              end
              files = inclusion.values.first
            else
              location = ""
              files = inclusion
            end
            
            files = [files] if files.is_a?(String)
            
            for f in files
              included_js << location + f
            end
          end
          write_inheritable_attribute(:included_js, included_js)
        end

        def css_include(*args)
          included_css = read_inheritable_attribute(:included_css) || []
          args.each do |inclusion|
            if inclusion.is_a?(Hash)
              # we are signalized a non-default file location (e.g. Ext examples)
              case inclusion.keys.first
              when :ext_examples
                location = Netzke::Base.config[:ext_location] + "/examples/"
              end
              files = inclusion.values.first
            else
              location = ""
              files = inclusion
            end
            
            files = [files] if files.is_a?(String)
            
            for f in files
              included_css << location + f
            end
          end
          write_inheritable_attribute(:included_css, included_css)
        end

        # returns all extra js-code (as string) required by this widget's class
        def js_included
          res = ""
          
          included_js = read_inheritable_attribute(:included_js) || []
          res << included_js.inject("") do |r, path|
            f = File.new(path)
            r << f.read
          end

          res
        end
        
        # returns all extra js-code (as string) required by this widget's class
        def css_included
          res = ""
          
          included_css = read_inheritable_attribute(:included_css) || []
          res << included_css.inject("") do |r, path|
            f = File.new(path)
            r << f.read
          end

          res
        end
        
        # all JS code needed for this class, including one from the ancestor widget
        def js_code(cached_dependencies = [])
          res = ""

          # include the base-class javascript if doing JS inheritance
          res << js_base_class.js_code << "\n" if js_inheritance && !cached_dependencies.include?(js_base_class.short_widget_class_name)

          # include static javascripts
          res << js_included << "\n"

          # our own JS class definition
          res << js_class
          res
        end

        # all JS code needed for this class including the one from the ancestor widget
        def css_code(cached_dependencies = [])
          res = ""

          # include the base-class javascript if doing JS inheritance
          res << js_base_class.css_code << "\n" if js_inheritance && !cached_dependencies.include?(js_base_class.short_widget_class_name)
          
          res << css_included << "\n"
          
          res
        end

        def this; "this".l; end
        def null; "null".l; end
      
      end
   
    end
  end
end