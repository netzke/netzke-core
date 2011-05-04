module Netzke
  module Railz
    module ActionViewExt
      # Implementation of Ext-specific helpers
      module Ext #:nodoc:

        protected

          def netzke_ext_css_include(params)
            # ExtJS base
            res = stylesheet_link_tag("/extjs4/resources/css/ext")

            # Netzke-related dynamic css
            res << "/netzke/ext"

            res += Netzke::Core.external_ext_css

            stylesheet_link_tag(res, :cache => false && params[:cache]) # caching is not possible at this time, as the stylesheets use relative asset paths
          end

          def netzke_ext_js_include
            res = []

            # ExtJS
            # TODO: Introduce production versions of Ext JS 4, when ready
            res << (ENV['RAILS_ENV'] == 'development' ? javascript_include_tag("/extjs4/ext-core-debug", "/extjs4/ext-all-debug") : javascript_include_tag("/extjs4/ext-core-debug", "/extjs/ext-all-debug"))

            # Netzke-related dynamic JavaScript
            res << "/netzke/ext"

            javascript_include_tag(res, :cache => params[:cache])
          end

          def netzke_ext_js(params)
            res = []
            res << content_for(:netzke_js_classes)
            res << "\n"

            res << "Ext.onReady(function(){"
            res << content_for(:netzke_on_ready)
            res << "});"

            javascript_tag(res.join("\n"))
          end

          # (Experimental) Embeds a "pure" (non-Netzke) Ext component into the view, e.g.:
          #     <%= ext :my_panel, :xtype => :panel, :html => "Simple Panel"
          def ext(name, config = {}) #:doc:
            comp = Netzke::ExtComponent.new(name, config)
            content_for :netzke_on_ready, raw("#{comp.js_component_render}")
            raw(comp.js_component_html)
          end

      end
    end
  end
end
