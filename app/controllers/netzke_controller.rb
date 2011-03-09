class NetzkeController < ApplicationController

  def ext
    respond_to do |format|
      format.js {
        res = initial_dynamic_javascript << "\n"

        include_base_js(res)

        # Ext-specific JavaScript
        res << File.new(File.expand_path("../../../javascripts/ext.js", __FILE__)).read

        # Pluggable JavaScript (used by other Netzke-powered gems like netzke-basepack)
        Netzke::Core.ext_javascripts.each do |path|
          f = File.new(path)
          res << f.read
        end

        render :text => defined?(::Rails) && ::Rails.env.production? ? res.strip_js_comments : res
      }

      format.css {
        res = File.new(File.expand_path("../../../stylesheets/core.css", __FILE__)).read

        # Pluggable stylesheets (may be used by other Netzke-powered gems like netzke-basepack)
        Netzke::Core.ext_stylesheets.each do |path|
          f = File.new(path)
          res << f.read
        end

        render :text => res
      }
    end
  end

  def touch
    respond_to do |format|
      format.js {
        res = initial_dynamic_javascript << "\n"

        include_base_js(res)
        # Touch-specific JavaScript
        res << File.new(File.expand_path("../../../javascripts/touch.js", __FILE__)).read

        # Pluggable JavaScript (may be used by other Netzke-powered gems like netzke-basepack)
        Netzke::Core.touch_javascripts.each do |path|
          f = File.new(path)
          res << f.read
        end

        render :text => defined?(::Rails) && ::Rails.env.production? ? res.strip_js_comments : res
      }

      format.css {
        res = File.new(File.expand_path("../../../stylesheets/core.css", __FILE__)).read

        # Pluggable stylesheets (may be used by other Netzke-powered gems like netzke-basepack)
        Netzke::Core.touch_stylesheets.each do |path|
          f = File.new(path)
          res << f.read
        end

        render :text => res
      }
    end
  end

  # Action for Ext.Direct RPC calls
  def direct
    result=""
    error=false
    if params['_json'] # this is a batched request
      params['_json'].each do |batch|
        result += result.blank? ? '[' : ', '
        begin
          result += invoke_endpoint(batch[:act], batch[:method].underscore, batch[:data].first, batch[:tid])
        rescue Exception  => e
          Rails.logger.error "!!! Netzke: Error invoking endpoint: #{batch[:act]} #{batch[:method].underscore} #{batch[:data].inspect} #{batch[:tid]}\n"
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
          error=true
          break;
        end
      end
      result+=']'
    else # this is a single request
      result=invoke_endpoint params[:act], params[:method].underscore, params[:data].first, params[:tid]
    end
    render :text => result, :layout => false, :status => error ? 500 : 200
  end

  # Action used by non-Ext.Direct (Touch) components
  def dispatcher
    endpoint_dispatch(params[:address])
  end

  protected

    def invoke_endpoint(endpoint_path, action, params, tid)
      component_name, *sub_components = endpoint_path.split('__')
      component_instance = Netzke::Base.instance_by_config(Netzke::Core.session[:netzke_components][component_name.to_sym])

      result = component_instance.invoke_endpoint((sub_components + [action]).join("__"), params)

      {
        :type => "rpc",
        :tid => tid,
        :action => component_name,
        :method => action,
        :result => result.present? && result.l || {}
      }.to_json
    end

    # Main dispatcher of old-style (Sencha Touch) HTTP requests. The URL contains the name of the component,
    # as well as the method of this component to be called, according to the double underscore notation.
    # E.g.: some_grid__post_grid_data.
    def endpoint_dispatch(endpoint_path)
      component_name, *sub_components = endpoint_path.split('__')
      component_instance = Netzke::Base.instance_by_config(Netzke::Core.session[:netzke_components][component_name.to_sym])

      # We render text/plain, so that the browser never modifies our response
      response.headers["Content-Type"] = "text/plain; charset=utf-8"

      render :text => component_instance.invoke_endpoint(sub_components.join("__"), params), :layout => false
    end

    # Generates initial javascript code that is dependent on Rails environement
    def initial_dynamic_javascript
      res = []
      res << %(Ext.Ajax.extraParams = {authenticity_token: '#{form_authenticity_token}'}; // Rails' forgery protection)
      res << %{Ext.ns('Netzke');}
      res << %{Ext.ns('Netzke.core');}
      res << %{Netzke.RelativeUrlRoot = '#{ActionController::Base.config.relative_url_root}';}
      res << %{Netzke.RelativeExtUrl = '#{ActionController::Base.config.relative_url_root}/extjs';}

      res << %{Netzke.core.directMaxRetries = '#{Netzke::Core.js_direct_max_retries}';}

      res.join("\n")
    end

    def include_base_js(arry)
      # JavaScript extensions
      arry << File.new(File.expand_path("../../../javascripts/core_extensions.js", __FILE__)).read

      # Base Netzke component JavaScript
      arry << File.new(File.expand_path("../../../javascripts/base.js", __FILE__)).read
    end

end
