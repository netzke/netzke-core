class NetzkeController < ApplicationController
  # Handles Ext.Direct RPC calls
  def direct
    if params['_json'] # this is a batched request
      response = []
      params['_json'].each do |batch|
        response << invoke_endpoint(batch)
      end
    else # this is a single request
      response = invoke_endpoint(params)
    end

    render text: response.to_json, layout: false
  end

  # On-the-fly generation of public/netzke/ext.[js|css]
  def ext
    respond_to do |format|
      format.js {
        render :text => Netzke::Core::DynamicAssets.ext_js(form_authenticity_token)
      }

      format.css {
        render :text => Netzke::Core::DynamicAssets.ext_css
      }
    end
  end

  # Old-way action used at multi-part form submission (endpointUrl)
  def dispatcher
    endpoint_dispatch(params[:address])
  end

protected

  def invoke_endpoint(request_params)
    path, action, params, tid = parse_request_params(request_params)

    component_name, *sub_components = path.split('__')
    components_in_session = session[:netzke_components]

    if components_in_session
      component_instance = Netzke::Base.instance_by_config(components_in_session[component_name.to_sym])
      result = component_instance.invoke_endpoint((sub_components + [action]).join("__"), params).netzke_jsonify
    else
      result = {:netzke_component_not_in_session => true}.netzke_jsonify
    end

    # We render text/plain, so that the browser never modifies our response
    response.headers["Content-Type"] = "text/plain; charset=utf-8"

    { :type => "rpc",
      :tid => tid,
      :action => component_name,
      :method => action,
      :result => ActiveSupport::JSON::Variable.new(result.to_json)
    }
  end

  def parse_request_params(params)
    path = params[:act]
    action = params[:method].underscore
    ep_params = params[:data].try(:first) # Rails >= 3.2.11 returns nil in request_params[:data]
    tid = params[:tid]

    [path, action, ep_params, tid]
  end

  # The dispatcher for the old-style requests (used for multi-part form submission). The URL contains the name of the component,
  # as well as the method of this component to be called, according to the double underscore notation.
  # E.g.: some_grid__post_grid_data.
  def endpoint_dispatch(endpoint_path)
    component_name, *sub_components = endpoint_path.split('__')
    component_instance = Netzke::Base.instance_by_config(session[:netzke_components][component_name.to_sym])

    # We can't do this here; this method is only used for classic form submission, and the response from the server should be the (default) "text/html"
    # response.headers["Content-Type"] = "text/plain; charset=utf-8"

    render :text => component_instance.invoke_endpoint(sub_components.join("__"), params).netzke_jsonify.to_json, :layout => false
  end

end
