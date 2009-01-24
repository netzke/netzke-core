module Netzke
  module ActionViewExt

    def netzke_js_include
      res = ""

      if ENV['RAILS_ENV'] == 'development'
        res << javascript_include_tag("/extjs/adapter/ext/ext-base.js", "/extjs/ext-all-debug.js")
      else
        res << javascript_include_tag("/extjs/adapter/ext/ext-base.js", "/extjs/ext-all.js")
      end
      res << javascript_tag( "Ext.authenticityToken = '#{form_authenticity_token}'") # forgery protection
      res << javascript_include_tag("/netzke/netzke.js")
      
      res
    end

    def netzke_css_include(theme_name = :default)
      res = stylesheet_link_tag("/extjs/resources/css/ext-all.css")
      res << stylesheet_link_tag("/extjs/resources/css/xtheme-#{theme_name}.css") unless theme_name == :default
      res << stylesheet_link_tag("/netzke/netzke.css") # CSS from Netzke
      res
    end
  end
end

