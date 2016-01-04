module Netzke
  module Railz
    # Before each request, Netzke::Base.controller and Netzke::Base.session are set, to be accessible from components.
    module ControllerExtensions
      class DirectRequest
        def initialize(params)
          @params = params
        end

        def cmp_path
          @params[:path]
        end

        def endpoint
          @params[:endpoint].underscore
        end

        # arguments for endpoint call
        def args
          res = remoting_args.has_key?("args") ? remoting_args["args"] : remoting_args
          res.is_a?(Array) ? res : [res].compact # need to wrap into array to normalize
        end

        def client_configs
          remoting_args["configs"] || []
        end

        def tid
          @params[:tid]
        end

      private

        # raw arguments from the client
        def remoting_args
          @_remoting_args ||= HashWithIndifferentAccess.new(@params.to_hash)[:data]
        end
      end

      extend ActiveSupport::Concern

      included do
        send(:before_filter, :set_controller_and_session)
      end

      module ClassMethods
        # inform AbstractController::Base that methods direct, ext, and dispatcher are actually actions
        def action_methods
          super.merge(%w[ext direct dispatcher].to_set)
        end
      end

      # Handles Ext.Direct RPC calls
      def direct
        if params['_json'] # this is a batched request
          response = []
          params['_json'].each do |batch|
            direct_request = DirectRequest.new(batch)
            response << direct_response(direct_request, invoke_endpoint(direct_request))
          end
        else # this is a single request
          direct_request = DirectRequest.new(params)
          response = direct_response(direct_request, invoke_endpoint(direct_request))
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

      # Receives DirectRequest and result of invoke_endpoint, returns hash understood by client-side's Direct function
      def direct_response(request, endpoint_response)
        component_name, *sub_components = request.cmp_path.split('__')

        # We render text/plain, so that the browser never modifies our response
        response.headers["Content-Type"] = "text/plain; charset=utf-8"

        { type: :rpc,
          tid: request.tid,
          action: component_name,
          method: request.endpoint,
          result: endpoint_response.netzke_jsonify
        }
      end

      # Receives DirectRequest, returns an array/hash of methods for the client side (consumed by netzkeBulkExecute)
      def invoke_endpoint(request)
        component_name, *sub_components = request.cmp_path.split('__')

        if cmp_config = config_in_session(component_name)
          cmp_config[:client_config] = request.client_configs.shift || {}
          component_instance = Netzke::Base.instance_by_config(cmp_config)
          component_instance.invoke_endpoint((sub_components + [request.endpoint]).join("__"), request.args, request.client_configs)
        else
          { netzke_on_session_expired: [] }
        end
      end

      # The dispatcher for the old-style requests (used for multi-part form submission). The URL contains the name of the component,
      # as well as the method of this component to be called, according to the double underscore notation.
      # E.g.: some_grid__post_grid_data.
      def endpoint_dispatch(endpoint_path)
        component_name, *sub_components = endpoint_path.split('__')

        if cmp_config = config_in_session(component_name)
          cmp_config[:client_config] = ActiveSupport::JSON.decode(params[:configs]).shift || {}
          component_instance = Netzke::Base.instance_by_config(cmp_config)

          render text: component_instance.invoke_endpoint(sub_components.join("__"), [params]).netzke_jsonify.to_json, layout: false
        else
          render text: { netzke_on_session_expired: [] }.to_json, layout: false
        end
      end

      def set_controller_and_session
        Netzke::Base.controller = self
        Netzke::Base.session = session
      end

      def config_in_session(component_name)
        components_in_session = (session[:netzke_components] || {}).symbolize_keys
        components_in_session[component_name.to_sym].try(:symbolize_keys)
      end
    end
  end
end
