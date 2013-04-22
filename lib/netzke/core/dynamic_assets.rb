module Netzke
  module Core
    module DynamicAssets
      class << self
        def ext_js(form_authenticity_token)
          res = initial_dynamic_javascript(form_authenticity_token) << "\n"

          include_base_js(res)

          # Ext-specific JavaScript
          res << File.new(File.expand_path("../../../../javascripts/ext.js", __FILE__)).read

          # Pluggable JavaScript (used by other Netzke-powered gems like netzke-basepack)
          Netzke::Core.ext_javascripts.each do |path|
            f = File.new(path)
            res << f.read
          end

          strip_js_comments(res)
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

        def strip_js_comments(js_string)
          if defined?(::Rails) && !::Rails.env.development? && compressor = ::Rails.application.assets.js_compressor
            compressor.processor.call(nil, js_string)
          else
            js_string
          end
        end

      private

        # Generates initial javascript code that is dependent on Rails settings
        def initial_dynamic_javascript(form_authenticity_token)
          res = []
          res << %(Ext.Ajax.extraParams = {authenticity_token: '#{form_authenticity_token}'}; // Rails' forgery protection)
          res << %{Ext.ns('Netzke');}
          res << %{Ext.ns('Netzke.core');}
          res << %{Netzke.RelativeUrlRoot = '#{ActionController::Base.config.relative_url_root}';}
          res << %{Netzke.ControllerUrl = '#{ActionController::Base.config.relative_url_root}#{Rails.application.routes.url_helpers.netzke_path('')}';}
          res << %{Netzke.RelativeExtUrl = '#{ActionController::Base.config.relative_url_root}#{Netzke::Core.ext_uri}';}

          res << %{Netzke.core.directMaxRetries = #{Netzke::Core.js_direct_max_retries};}
          res << %{Netzke.core.FeedbackDelay = #{Netzke::Core.js_feedback_delay};}

          res.join("\n")
        end

        def include_base_js(arry)
          # JavaScript extensions
          arry << File.new(File.expand_path("../../../../javascripts/js_extensions.js", __FILE__)).read

          # Base Netzke component JavaScript
          arry << File.new(File.expand_path("../../../../javascripts/base.js", __FILE__)).read
        end

      end
    end
  end
end
