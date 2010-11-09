require 'netzke/rails/action_view_ext/touch'
module Netzke
  module Rails
    module ActionViewExt
      module Touch

        def netzke_touch(name, config = {})
          @rendered_touch_classes ||= []

          # if we are the first netzke call on the page, reset components hash in the session
          if @rendered_touch_classes.empty?
            Netzke::Core.reset_components_in_session
          end

          class_name = config[:class_name] ||= name.to_s.camelcase

          config[:name] = name

          Netzke::Core.reg_component(config)

          w = Netzke::Base.instance_by_config(config)
          w.before_load # inform the component about initial load

          if Netzke::Core.javascript_on_main_page
            content_for :netzke_js_classes, raw(w.js_missing_code(@rendered_touch_classes))
          end

          content_for :netzke_css, raw(w.css_missing_code(@rendered_touch_classes))

          content_for :netzke_touch_on_ready, raw("#{w.js_component_instance}\n\n#{w.js_component_render}")

          # Now mark this component's class as rendered, so that we only generate it once per view
          @rendered_touch_classes << class_name unless @rendered_touch_classes.include?(class_name)

          # Return the html for this component
          raw(w.js_component_html)
        end

        def netzke_touch_init
          raw([netzke_touch_css_include, netzke_touch_js_include, netzke_touch_js].join("\n"))
        end

        def netzke_touch_js
          res = []
          res << content_for(:netzke_js_classes)
          res << "\n"

          res << "Ext.setup({"
            res << "onReady: function(){"
            res << content_for(:netzke_touch_on_ready)
            res << "}"
          res << "});"

          javascript_tag res.join("\n")
        end


        def netzke_touch_css_include
          # ExtJS base
          res = stylesheet_link_tag("/sencha-touch/resources/css/sencha-touch")
          # Netzke (dynamically generated)
          #res << "\n" << stylesheet_link_tag("/netzke/netzke")

          # External stylesheets (which cannot be loaded dynamically along with the rest of the component, e.g. due to that
          # relative paths are used in them)
          #res << "\n" << stylesheet_link_tag(Netzke::Core.external_css)

          res
        end


        def netzke_touch_js_include
          res = []

          # ExtJS
          res << (ENV['RAILS_ENV'] == 'development' ? javascript_include_tag("/sencha-touch/sencha-touch-debug.js") : javascript_include_tag("/sencha-touch/sencha-touch"))

          # Netzke (dynamically generated)
          res << javascript_include_tag("/netzke/touch")

          res.join("\n")
        end
      end
    end
  end
end
