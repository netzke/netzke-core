module Netzke
  module ActionViewExt
    # Include JavaScript
    def netzke_js_include
      res = []
      
      # ExtJS
      res << (ENV['RAILS_ENV'] == 'development' ? javascript_include_tag("/extjs/adapter/ext/ext-base-debug", "/extjs/ext-all-debug") : javascript_include_tag("/extjs/adapter/ext/ext-base", "/extjs/ext-all"))
      
      # Netzke (dynamically generated)
      res << javascript_include_tag("/netzke/netzke")
      res.join("\n")
    end

    # Include CSS
    def netzke_css_include(theme_name = "default")
      # ExtJS base
      res = stylesheet_link_tag("/extjs/resources/css/ext-all")
      # ExtJS theming
      res << "\n" << stylesheet_link_tag("/extjs/resources/css/xtheme-#{theme_name}") unless theme_name.to_s == "default"
      # Netzke (dynamically generated)
      res << "\n" << stylesheet_link_tag("/netzke/netzke")
      
      # External stylesheets (which cannot be loaded dynamically along with the rest of the component, e.g. due to that 
      # relative paths are used in them)
      res << "\n" << stylesheet_link_tag(Netzke::Core.external_css)
      
      res
    end
    
    # JavaScript for all Netzke classes in this view, and Ext.onReady which renders all Netzke components in this view
    def netzke_js
      res = []
      if Netzke::Core.javascript_on_main_page
        res << content_for(:netzke_js_classes)
        res << "\n"
      end
      res << "Ext.onReady(function(){"
      res << content_for(:netzke_on_ready)
      res << "});"
      
      javascript_tag res.join("\n")
    end
    
    def netzke_css
      %{
<style type="text/css" media="screen">
  #{content_for(:netzke_css)}
</style>}
    end
    
    # Wrapper for all the above. Use it in your layout.
    # Params: <tt>:ext_theme</tt> - the name of ExtJS theme to apply (optional)
    # E.g.:
    #   <%= netzke_init :ext_theme => "grey" %>
    def netzke_init(params = {})
      theme = params[:ext_theme] || :default
      raw([netzke_css_include(theme), netzke_css, netzke_js_include, netzke_js].join("\n"))
    end
    
    # Use this helper in your views to embed Netzke components. E.g.:
    #   netzke :my_grid, :class_name => "Basepack::GridPanel", :columns => [:id, :name, :created_at]
    # On how to configure a component, see documentation for Netzke::Base or/and specific component
    def netzke(name, config = {})
      @rendered_classes ||= []
      
      # if we are the first netzke call on the page, reset components hash in the session
      if @rendered_classes.empty?
        Netzke::Core.reset_components_in_session
      end
      
      class_name = config[:class_name] ||= name.to_s.camelcase
      
      config[:name] = name
      
      Netzke::Core.reg_component(config)
      
      w = Netzke::Base.instance_by_config(config)
      w.before_load # inform the component about initial load
      
      if Netzke::Core.javascript_on_main_page
        content_for :netzke_js_classes, raw(w.js_missing_code(@rendered_classes))
      end
      
      content_for :netzke_css, raw(w.css_missing_code(@rendered_classes))
      
      content_for :netzke_on_ready, raw("#{w.js_component_instance}\n\n#{w.js_component_render}")
      
      # Now mark this component's class as rendered, so that we only generate it once per view
      @rendered_classes << class_name unless @rendered_classes.include?(class_name)

      # Return the html for this component
      raw(w.js_component_html)
    end
    
    def ext(name, config = {})
      comp = Netzke::ExtComponent.new(name, config)
      content_for :netzke_on_ready, raw("#{comp.js_component_render}")
      raw(comp.js_component_html)
    end
  end
end

