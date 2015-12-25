require 'uglifier'

module Netzke
  module Core
    module DynamicAssets
      CORE_FILES = %w[js_extensions core notifications remoting_provider component routing]

      class << self
        def ext_js(form_authenticity_token)
          res = initial_dynamic_javascript(form_authenticity_token) << "\n"

          include_core_js(res)

          # Pluggable JavaScript (used by other Netzke-powered gems like netzke-basepack)
          Netzke::Core.ext_javascripts.each do |path|
            f = File.new(path)
            res << f.read
          end

          minify_js(res)
        end

        def ext_css
          res = File.new(File.expand_path("../../../../stylesheets/core.css", __FILE__)).read

          # Pluggable stylesheets (may be used by other Netzke-powered gems like netzke-basepack)
          Netzke::Core.ext_stylesheets.each do |path|
            f = File.new(path)
            res << f.read
          end

          res
        end

        def minify_js(js_string)
          if ::Rails.env.test? || ::Rails.env.development?
            js_string.gsub(/\/\*\*[^*]*\*+(?:[^*\/][^*]*\*+)*\//, '') # strip docs
          else
            Uglifier.compile(js_string)
          end
        end

      private

        # Generates initial javascript code that is dependent on Rails settings
        def initial_dynamic_javascript(form_authenticity_token)
          url_root = ActionController::Base.config.relative_url_root
          %(Ext.Ajax.setExtraParams({authenticity_token: '#{form_authenticity_token}'});
Ext.ns('Netzke.Core');
Netzke.RelativeUrlRoot = '#{url_root}';
Netzke.ControllerUrl = '#{url_root}#{Rails.application.routes.url_helpers.netzke_path}/';
Netzke.RelativeExtUrl = '#{url_root}#{Netzke::Core.ext_uri}';
Netzke.Core.directMaxRetries = #{Netzke::Core.js_direct_max_retries};
Netzke.Core.NotificationDelay = #{Netzke::Core.client_notification_delay};
)
        end

        def include_core_js(arry)
          CORE_FILES.each do |script|
            arry << File.new(File.expand_path("../../../../javascripts/#{script}.js", __FILE__)).read
          end
        end
      end
    end
  end
end
