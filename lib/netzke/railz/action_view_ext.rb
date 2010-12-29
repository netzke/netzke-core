require 'netzke/railz/action_view_ext/ext'
require 'netzke/railz/action_view_ext/touch'
module Netzke
  module Railz
    module ActionViewExt
      include Ext
      include Touch

      # A helper to initialize Netzke. Usually used in the layout.
      #
      # Params:
      # * :platform - :ext or :touch, by default :ext
      # * :theme - the name of theme to apply
      #
      # E.g.:
      #     <%= netzke_init :theme => :grey %>
      #
      # For Sencha Touch:
      #     <%= netzke_init :platform => :touch %>
      def netzke_init(params = {})
        Netzke::Core.platform = params[:platform] || :ext
        theme = params[:theme] || params[:ext_theme] || :default
        raw([netzke_css_include(theme), netzke_css, netzke_js_include, netzke_js].join("\n"))
      end

      # Use this helper in your views to embed Netzke components. E.g.:
      #     netzke :my_grid, :class_name => "Basepack::GridPanel", :columns => [:id, :name, :created_at]
      def netzke(name, config = {})
        @rendered_classes ||= []

        # if we are the first netzke call on the page, reset components hash in the session
        # if @rendered_classes.empty?
        #   Netzke::Core.reset_components_in_session
        # end

        class_name = config[:class_name] ||= name.to_s.camelcase

        config[:name] = name

        # Register the component in session
        Netzke::Core.reg_component(config)

        w = Netzke::Base.instance_by_config(config)
        w.before_load # inform the component about initial load

        content_for :netzke_js_classes, raw(w.js_missing_code(@rendered_classes))

        content_for :netzke_css, raw(w.css_missing_code(@rendered_classes))

        content_for :netzke_on_ready, raw("#{w.js_component_instance}\n\n#{w.js_component_render}")

        # Now mark this component's class as rendered (by storing it's xtype), so that we only generate it once per view
        @rendered_classes << class_name.to_s.gsub("::", "").downcase unless @rendered_classes.include?(class_name)

        # Return the html for this component
        raw(w.js_component_html)
      end

      protected

        # Link tags for all the required stylsheets
        def netzke_css_include(theme)
          send :"netzke_#{Netzke::Core.platform}_css_include", theme
        end

        # Inline CSS specific for the page
        def netzke_css
          %{
    <style type="text/css" media="screen">
      #{content_for(:netzke_css)}
    </style>} if content_for(:netzke_css).present?
        end

        # Script tags for all the required JavaScript
        def netzke_js_include
          send :"netzke_#{Netzke::Core.platform}_js_include"
        end

        # Inline JavaScript for all Netzke classes on the page, as well as Ext.onReady (Ext.setup in case of Touch) which renders Netzke components in this view after the page is loaded
        def netzke_js
          send :"netzke_#{Netzke::Core.platform}_js"
        end

    end
  end
end
