module Netzke
  module Railz
    module ActionViewExt
      # Implementation of Ext-specific Netzke helpers
      module Ext

      private

        def netzke_ext_css_include(params)
          # ExtJS base
          res = ["#{Netzke::Core.ext_uri}/packages/ext-theme-#{params[:theme]}/build/resources/ext-theme-#{params[:theme]}-all.css"]

          # Netzke-related dynamic css
          res << netzke_ext_path

          res += Netzke::Core.external_ext_css

          stylesheet_link_tag(*res)
        end

        def netzke_ext_js_include(params)
          res = []

          # ExtJS
          res << (params[:minified] ? "#{Netzke::Core.ext_uri}/build/ext-all.js" : "#{Netzke::Core.ext_uri}/build/ext-all-debug.js")

          # Ext I18n
          res << "#{Netzke::Core.ext_uri}/packages/ext-locale/build/ext-locale-#{I18n.locale}" if I18n.locale != :en

          # Netzke-related dynamic JavaScript
          res << netzke_ext_path

          javascript_include_tag(*res)
        end

        def netzke_ext_js(params)
          res = []
          res << content_for(:netzke_js_classes)

          res << "Ext.onReady(function(){"
          res << content_for(:netzke_on_ready)
          res << "});"

          javascript_tag(res.join("\n"))
        end
      end
    end
  end
end
