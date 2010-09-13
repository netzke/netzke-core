module Netzke
  module ActionViewExt
    # Include JavaScript
    def netzke_js_include
      # ExtJS
      res = ENV['RAILS_ENV'] == 'development' ? javascript_include_tag("/extjs/adapter/ext/ext-base", "/extjs/ext-all-debug") : javascript_include_tag("/extjs/adapter/ext/ext-base", "/extjs/ext-all")
      # Netzke (dynamically generated)
      res << javascript_include_tag("/netzke/netzke")
    end

    # Include CSS
    def netzke_css_include(theme_name = :default)
      # ExtJS base
      res = stylesheet_link_tag("/extjs/resources/css/ext-all")
      # ExtJS theming
      res << stylesheet_link_tag("/extjs/resources/css/xtheme-#{theme_name}") unless theme_name == :default
      # Netzke (dynamically generated)
      res << stylesheet_link_tag("/netzke/netzke")
      
      # External stylesheets (which cannot be loaded dynamically along with the rest of the widget, e.g. due to that 
      # relative paths are used in them)
      res << stylesheet_link_tag(Netzke::Base.config[:external_css])
      
      res
    end
    
    # JavaScript for all Netzke classes in this view, and Ext.onReady which renders all Netzke widgets in this view
    def netzke_js
      js="Ext.Ajax.extraParams = {authenticity_token: '#{form_authenticity_token}'}; // Rails' forgery protection\n"


      js << <<-END_OF_JAVASCRIPT if(!ActionController::Base.relative_url_root.blank?)
        // apply relative URL root, if set
        Ext.widgetMixIn.buildApiUrl= function(apip){
          return "#{ActionController::Base.relative_url_root}/netzke/" + this.id + "__" + apip;
        };
        Ext.BLANK_IMAGE_URL = "#{ActionController::Base.relative_url_root}/extjs/resources/images/default/s.gif";
      END_OF_JAVASCRIPT

      js << <<-END_OF_JAVASCRIPT
        #{@content_for_netzke_js_classes}
        Ext.onReady(function(){
          #{@content_for_netzke_on_ready}
        });
      END_OF_JAVASCRIPT

      javascript_tag js
      
    end

		def netzke_css
			%{
				<style type="text/css" media="screen">
					#{content_for(:netzke_css)}
				</style>
			}
		end
    
    # Wrapper for all the above. Use it in your layout.
    # Params: <tt>:ext_theme</tt> - the name of ExtJS theme to apply (optional)
    # E.g.:
    #   <%= netzke_init :ext_theme => "grey" %>
    def netzke_init(params = {})
      theme = params[:ext_theme] || :default
      [netzke_css_include(theme), netzke_js_include, netzke_css , netzke_js].join("\n")
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
      w.before_load # inform the widget about initial load
      content_for :netzke_js_classes, w.js_missing_code(@rendered_classes ||= [])
      content_for :netzke_on_ready, "#{w.js_widget_instance}\n\n#{w.js_widget_render}"
			content_for :netzke_css, w.css_missing_code(@rendered_classes ||= [])
      
      # Now mark this widget's class as rendered, so that we only generate it once per view
      @rendered_classes << class_name unless @rendered_classes.include?(class_name)

      # Return the html for this widget
      w.js_widget_html
    end
  end
end

