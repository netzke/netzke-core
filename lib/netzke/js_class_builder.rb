module Netzke
  # 
  # Module which provides JS-class generation functionality for the widgets ("client-side"). This code is executed only once per widget class, and the results are cached at the server (unless widget specifies config[:no_caching] => true).
  # Included into Netzke::Base class
  # Most of the methods below are meant to be overwritten by a concrete widget class.
  # 
  module JsClassBuilder
    # the JS (Ext) class that we inherit from
    def js_base_class; "Ext.Panel"; end

    # widget's actions that are loaded at the moment of instantiating a widget
    def actions; null; end

    # widget's tools that are loaded at the moment of instantiating a widget see (js_config method)
    def tools; []; end
    
    def tbar; null; end

    def bbar; null; end

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

    # default config that is passed into the constructor
    def js_default_config
      {
        :title => short_widget_class_name,
        :listeners => js_listeners,
        :tools => "config.tools".l,
        :actions => "config.actions".l,
        :tbar => "config.tbar".l,
        :bbar => "config.bbar".l,
        :items => js_items,
        :height => 400,
        :width => 800,
        :border => false
      }
    end

    # declaration of widget's class (stored directly in the cache storage at the client side to be reused at the moment of widget instantiation)
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

    # generate instantiating - used when a widget is generated stand-alone (as a part of a HTML page)
    def js_widget_instance
      %Q(var #{config[:name].to_js} = new Ext.componentCache['#{short_widget_class_name}'](#{js_config.to_js});)
    end

    # the config that is send from the server and is used for instantiating a widget
    def js_config
      res = {}
      
      # recursively include configs of all (non-late) aggregatees, so that the widget can instantiate them, too
      aggregatees.each_pair do |aggr_name, aggr_config|
        next if aggr_config[:late_aggregation]
        res["#{aggr_name}_config".to_sym] = aggregatee_instance(aggr_name.to_sym).js_config
      end
      
      # interface
      interface = interface_points.inject({}){|h,interfacep| h.merge(interfacep => widget_action(interfacep))}
      res.merge!(:interface => interface)
      
      res.merge!(:widget_class_name => short_widget_class_name)

      res.merge!(config[:ext_config])
      res.merge!(:id => @id_name)
      
      # include tools and actions
      res.merge!(:tools => tools)
      res.merge!(:actions => actions)
      res
    end

    # class definition of the widget plus that of all the dependencies, minus those that are specified as dependencies_to_exclude
    def js_missing_code(dependencies_to_exclude = [])
      result = ""
      dependencies.each do |dep_name|
        dependency_class = "Netzke::#{dep_name}".constantize
        result << dependency_class.new(config).js_missing_code(dependencies_to_exclude)
      end
      result << js_class unless dependencies_to_exclude.include?(short_widget_class_name) && !config[:no_caching]
      result
    end
   
    # little helpers
    def this; "this".l; end
    def null; "null".l; end
  end
end