module Netzke
  module Core
    module DynamicAssets
      class << self
        def touch_js
          res = initial_dynamic_javascript << "\n"

          include_base_js(res)
          # Touch-specific JavaScript
          res << File.new(File.expand_path("../../../../javascripts/touch.js", __FILE__)).read

          # Pluggable JavaScript (may be used by other Netzke-powered gems like netzke-basepack)
          Netzke::Core.touch_javascripts.each do |path|
            f = File.new(path)
            res << f.read
          end

          defined?(::Rails) && ::Rails.env.production? ? res.strip_js_comments : res
        end

        def touch_css
          res = File.new(File.expand_path("../../../../stylesheets/core.css", __FILE__)).read

          # Pluggable stylesheets (may be used by other Netzke-powered gems like netzke-basepack)
          Netzke::Core.touch_stylesheets.each do |path|
            f = File.new(path)
            res << f.read
          end

          res
        end

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

          defined?(::Rails) && ::Rails.env.production? ? res.strip_js_comments : res
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

        protected

          # Generates initial javascript code that is dependent on Rails settings
          def initial_dynamic_javascript(form_authenticity_token)
            res = []
            res << %(Ext.Ajax.extraParams = {authenticity_token: '#{form_authenticity_token}'}; // Rails' forgery protection)
            res << %{Ext.ns('Netzke');}
            res << %{Ext.ns('Netzke.core');}
            res << %{Netzke.RelativeUrlRoot = '#{ActionController::Base.config.relative_url_root}';}
            res << %{Netzke.RelativeExtUrl = '#{ActionController::Base.config.relative_url_root}#{Netzke::Core.ext_uri}';}

            res << %{Netzke.core.directMaxRetries = '#{Netzke::Core.js_direct_max_retries}';}

            res.join("\n")
          end

          def include_base_js(arry)
            # JavaScript extensions
            arry << File.new(File.expand_path("../../../../javascripts/core_extensions.js", __FILE__)).read

            # Base Netzke component JavaScript
            arry << File.new(File.expand_path("../../../../javascripts/base.js", __FILE__)).read
          end

        # end protected

      end

    end
  end
end
