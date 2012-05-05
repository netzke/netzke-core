class NetzkeController < ApplicationController
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

  def invoke_endpoint(endpoint_path, action, params, tid) #:nodoc:
    component_name, *sub_components = endpoint_path.split('__')
    components_in_session = Netzke::Core.session[:netzke_components]

    if components_in_session
      component_instance = Netzke::Base.instance_by_config(components_in_session[component_name.to_sym])
      result = component_instance.invoke_endpoint((sub_components + [action]).join("__"), params).to_nifty_json
    else
      result = {:component_not_in_session => true}.to_nifty_json
    end

    {
      :type => "rpc",
      :tid => tid,
      :action => component_name,
      :method => action,
      :result => result.present? && result.l || {}
    }.to_json
  end

  # The dispatcher for the old-style requests (used for multi-part form submission). The URL contains the name of the component,
  # as well as the method of this component to be called, according to the double underscore notation.
  # E.g.: some_grid__post_grid_data.
  def endpoint_dispatch(endpoint_path)
    component_name, *sub_components = endpoint_path.split('__')
    component_instance = Netzke::Base.instance_by_config(Netzke::Core.session[:netzke_components][component_name.to_sym])

    # We render text/plain, so that the browser never modifies our response
    response.headers["Content-Type"] = "text/plain; charset=utf-8"

    render :text => component_instance.invoke_endpoint(sub_components.join("__"), params).to_nifty_json, :layout => false
  end

end
