module Netzke
  # == BaseJs
  # *TODO: outdated*
  # 
  # Module which provides JS-class generation functionality for the widgets ("client-side"). The generated code 
  # is evaluated once per widget class, and the results are cached in the browser. Included into Netzke::Base class.
  # 
  # == Widget javascript code
  # Here's a brief explanation on how a javascript class for a widget gets built.
  # Widget gets defined as a constructor (a function) by +js_class+ class method (see "Inside widget's contstructor").
  # +Ext.extend+ provides inheritance from an Ext class specified in +js_base_class+ class method.
  # 
  # == Inside widget's constructor
  # * Widget's constructor gets called with a parameter that is a configuration object provided by +js_config+ instance method. This configuration is specific for the instance of the widget, and, for example, contains this widget's unique id. As another example, by means of this configuration object, a grid receives the configuration array for its columns, a form - for its fields, etc. With other words, everything that may change from instance to instance of the same widget's class, goes in here.
  # * Widget executes its specific initialization code which is provided by +js_before_consttructor+ class method. 
  # For example, a grid may define its column model, a form - its fields, a tab panel - its tabs ("items").
  # * Widget calls the constructor of the inherited class (see +js_class+ class method) with a parameter that is a merge of 
  # 1) configuration parameter passed to the widget's constructor.
  module BaseJs
    def self.included(base)
      base.extend ClassMethods
    end

    #
    # The following methods are used when a widget is generated stand-alone (as a part of a HTML page)
    #

    # instantiating
    def js_widget_instance
      %Q{Netzke.page.#{name.jsonify} = new #{self.class.js_full_class_name}(#{js_config.to_nifty_json});}
    end

    # rendering
    def js_widget_render
      %Q{Netzke.page.#{name.jsonify}.render("#{name.to_s.split('_').join('-')}-netzke");} unless self.class.js_xtype == "netzkewindow"
    end

    # container for rendering
    def js_widget_html
      %Q{<div id="#{name.to_s.split('_').join('-')}-netzke" class="netzke-widget"></div>}
    end

 
    def menu; nil; end

    # Methods used to create the javascript class (only once per widget class). 
    # The generated code gets cached at the browser, and the widget intstances (at the browser side)
    # get instantiated from it.
    # All these methods can be overwritten in case you want to extend the functionality of some pre-built widget
    # instead of using it as is (using both would cause JS-code duplication)
    module ClassMethods
    end
  end
end