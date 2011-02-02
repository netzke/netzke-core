class NetzkeController < ApplicationController

  # Collect javascripts and stylesheets from all plugins that registered it in Netzke::Core.javascripts
  # TODO: caching
  # caches_action :netzke
  def ext
    respond_to do |format|
      format.js {
        res = initial_dynamic_javascript << "\n"

        # Core JavaScript
        res << File.new(File.expand_path("../../../javascripts/core.js", __FILE__)).read
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

        # Core JavaScript
        res << File.new(File.expand_path("../../../javascripts/core.js", __FILE__)).read
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
  
  private
  def invoke_endpoint component_name, action, data, tid
    data=data[0] || {} # we get data as an array, extract the single argument if available

    root_component_name, *sub_components = component_name.split('__')
    root_component = Netzke::Base.instance_by_config Netzke::Core.session[:netzke_components][root_component_name.to_sym]
    if sub_components.empty?
      # we need to dispatch to root component, send it _#{action}_ep_wrapper
      endpoint_action = "_#{action}_ep_wrapper"
    else
      # we need to dispatch to one or more sub_components, send subcomp__subsubcomp__endpoint to root component
      endpoint_action = sub_components.join('__')+'__'+action      
    end
    # send back JSON as specified in Ext.direct spec
    #  => type: rpc
    #  => tid, action, method as in the request, so that the client can mark the transaction and won't retry it
    #  => result: JavaScript code from he endpoint result which gets applied to the client-side component instance
    result=root_component.send(endpoint_action, data)    
    return "{ \"type\": \"rpc\", \"tid\": #{tid}, \"action\": \"#{component_name}\", \"method\": \"#{action}\", \"result\": #{result.blank? ? '{}' : result}}"
  end
  public  

  # Handler for Ext.Direct RPC calls
  def direct
    result=""
    if params['_json'] # this is a batched request
      params['_json'].each do |batch|
        result+= result.blank? ? '[' : ', '
        result+=invoke_endpoint batch[:act], batch[:method].underscore, batch[:data], batch[:tid]
      end
      result+=']'
    else # this is a single request
      result=invoke_endpoint params[:act], params[:method].underscore, params[:data], params[:tid]
    end
    render :text => result, :layout => false    
  end

  # Main dispatcher of the HTTP requests. The URL contains the name of the component,
  # as well as the method of this component to be called, according to the double underscore notation.
  # E.g.: some_grid__post_grid_data.
  def method_missing(method_name)
    component_name, *action = method_name.to_s.split('__')
    component_name = component_name.to_sym
    action = !action.empty? && action.join("__").to_sym

    if action
      w_instance = Netzke::Base.instance_by_config(Netzke::Core.session[:netzke_components][component_name])
      # only component's actions starting with "endpoint_" are accessible from outside (security)
      endpoint_action = action.to_s.index('__') ? action : "_#{action}_ep_wrapper"
      render :text => w_instance.send(endpoint_action, params), :layout => false
    else
      super
    end
  end

  private
    # Generates initial javascript code that is dependent on Rails environement
    def initial_dynamic_javascript
      res = []
      res << %(Ext.Ajax.extraParams = {authenticity_token: '#{form_authenticity_token}'}; // Rails' forgery protection)
      res << %{Ext.ns('Netzke');}
      res << %{Netzke.RelativeUrlRoot = '#{ActionController::Base.config.relative_url_root}';}
      res << %{Netzke.RelativeExtUrl = '#{ActionController::Base.config.relative_url_root}/extjs';}
      res.join("\n")
    end

end
