module Netzke
  module ActionViewExt
    # Include JavaScript
    def netzke_js_include
      # ExtJS
      res = ENV['RAILS_ENV'] == 'development' ? javascript_include_tag("/extjs/adapter/ext/ext-base.js", "/extjs/ext-all-debug.js") : javascript_include_tag("/extjs/adapter/ext/ext-base.js", "/extjs/ext-all.js")
      # Netzke (dynamically generated)
      res << javascript_include_tag("/netzke/netzke.js")
    end

    # Include CSS
    def netzke_css_include(theme_name = :default)
      # ExtJS base
      res = stylesheet_link_tag("/extjs/resources/css/ext-all.css")
      # ExtJS theming
      res << stylesheet_link_tag("/extjs/resources/css/xtheme-#{theme_name}.css") unless theme_name == :default
      # Netzke (dynamically generated)
      res << stylesheet_link_tag("/netzke/netzke.css")
      res
    end
    
    # JavaScript for all Netzke classes in this view, and Ext.onReady which renders all Netzke widgets in this view
    def netzke_js
      javascript_tag <<-END_OF_JAVASCRIPT
        Ext.Ajax.extraParams = {authenticity_token: '#{form_authenticity_token}'}; // Rails' forgery protection... effective?
        #{@content_for_netzke_js_classes}
        Ext.onReady(function(){
          #{@content_for_netzke_on_ready}
        });
      END_OF_JAVASCRIPT
    end
    
    # Wrapper for all the above. Use it in your layout.
    # Params: <tt>:ext_theme</tt> - the name of ExtJS theme to apply (optional)
    # E.g.:
    #   <%= netzke_init :ext_theme => "grey" %>
    def netzke_init(params = {})
      theme = params[:ext_theme] || :default
      [netzke_css_include(theme), netzke_js_include, netzke_js].join("\n")
    end
    
    # Use this helper in your views to embed Netzke widgets. E.g.:
    #   netzke :my_grid, :class_name => "GridPanel", :columns => [:id, :name, :created_at]
    # On how to configure a widget, see documentation for Netzke::Base or/and specific widget
    def netzke(name, config = {})
      ::ActiveSupport::Deprecation.warn("widget_class_name option is deprecated. Use class_name instead", caller) if config[:widget_class_name]
      class_name = config[:class_name] ||= config[:widget_class_name] || name.to_s.camelcase
      config[:name] = name
      Netzke::Base.reg_widget(config)
      w = Netzke::Base.instance_by_config(config)
      content_for :netzke_js_classes, w.js_missing_code(@rendered_classes ||= [])
      content_for :netzke_on_ready, w.js_widget_instance
      content_for :netzke_on_ready, w.js_widget_render
      
      # Now mark this widget's class as rendered, so that we only generate it once per view
      @rendered_classes << class_name unless @rendered_classes.include?(class_name)

      # Return the html for this widget
      w.js_widget_html
    end
  end
end

