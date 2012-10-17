require 'netzke/railz/action_view_ext/ext'
module Netzke
  module Railz
    module ActionViewExt
      include Ext

      # A helper to initialize Netzke. Usually used in the layout.
      #
      # Params:
      # * :platform - defaults to :ext
      # * :theme - the name of theme to apply
      # * :cache - enable Rails caching of assets
      #
      # E.g.:
      #     <%= load_netzke :theme => :grey %>
      def load_netzke(params = {})
        Netzke::Core.platform = params[:platform] || :ext
        theme = params[:theme] || params[:ext_theme]

        raw([netzke_css_include(params), netzke_css(params), netzke_js_include(params), netzke_js(params)].join("\n"))
      end

      # Use this helper in your views to embed Netzke components. E.g.:
      #     netzke :my_grid, :class_name => "Basepack::GridPanel", :columns => [:id, :name, :created_at]
      def netzke(name, config = {})
        @rendered_classes ||= []

        # If we are the first netzke call on the page, reset components hash in the session.
        # WON'T WORK, because it breaks the browser "back" button
        # if @rendered_classes.empty?
        #   Netzke::Core.reset_components_in_session
        # end

        class_name = config[:class_name] ||= name.to_s.camelcase

        config[:name] = name

        # Register the component in session
        Netzke::Core.reg_component(config)

        cmp = Netzke::Base.instance_by_config(config)
        cmp.before_load # inform the component about initial load

        content_for :netzke_js_classes, raw(cmp.js_missing_code(@rendered_classes))

        content_for :netzke_css, raw(cmp.css_missing_code(@rendered_classes))

        content_for :netzke_on_ready, raw("#{cmp.js_component_instance}\n\n#{cmp.js_component_render}")

        # Now mark all this component's dependency classes (including self) as rendered (by storing their xtypes), so that we only generate a class once per view
        @rendered_classes = (@rendered_classes + cmp.dependency_classes.map(&:js_xtype)).uniq

        # Return the html for this component
        raw(cmp.js_component_html)
      end

      protected

        # Link tags for all the required stylsheets
        def netzke_css_include(params)
          send :"netzke_#{Netzke::Core.platform}_css_include", params
        end

        # Inline CSS specific for the page
        def netzke_css(params)
          %{
    <style type="text/css" media="screen">
      #{content_for(:netzke_css)}
    </style>} if content_for(:netzke_css).present?
        end

        # Script tags for all the required JavaScript
        def netzke_js_include(params)
          send :"netzke_#{Netzke::Core.platform}_js_include", params
        end

        # Inline JavaScript for all Netzke classes on the page, as well as Ext.onReady, which renders Netzke components in this view after the page is loaded
        def netzke_js(params = {})
          send :"netzke_#{Netzke::Core.platform}_js", params
        end

    end

  end
end
