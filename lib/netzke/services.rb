module Netzke
  # This module takes care of components' client-server communication.
  module Services
    extend ActiveSupport::Concern

    module ClassMethods
      # Defines an endpoint - a connection point between the client side of a component and its server side. For example:
      #
      #     endpoint :do_something do |params|
      #       # ...
      #     end
      #
      # By defining the endpoint on the server, the client side automatically gets a method that is used to call the server, in this case `doSomething` (note conversion from underscore to camelcase). It can be called like this:
      #
      #     this.doSomething(argsObject, callbackFunction, scope);
      #
      # * +argsObject+ is what the server side will receive as the +params+ argument
      # * +callbackFunction+ (optional) will be called after the server successfully processes the request
      # * +scope+ (optional) the scope in which +callbackFunction+ will be called
      #
      # The callback function may receive an argument which will be set to the value that the server passes to the special +set_result+ key in the resulting hash:
      #
      #     endpoint :do_something do |params|
      #       # ...
      #       {:set_result => 42}
      #     end
      #
      # Any other key in the resulting hash will result in a corresponding JavaScript-side function call, with the parameter set to the value of that key. For example:
      #
      #     endpoint :do_something do |params|
      #       # ...
      #       {:set_result => 42, :set_title => "New title, set by the server"}
      #     end
      #
      # This will result in the call to the +setTitle+ method on the client side of the component, with "New title, set by the server" as the parameter.
      def endpoint(name, options = {}, &block)
        register_endpoint(name, options)
        define_method("#{name}_endpoint", &block) if block # if no block is given, the method is supposed to be defined elsewhere

        # define_method name, &block if block # if no block is given, the method is supposed to be defined elsewhere
        define_method :"_#{name}_ep_wrapper" do |*args|
          res = send("#{name}_endpoint", *args)
          res.respond_to?(:to_nifty_json) && res.to_nifty_json || ""
        end
      end

      # Returns all endpoints as a hash
      def endpoints
        read_inheritable_attribute(:endpoints) || {}
      end

      def api(*api_points) #:nodoc:
        ::ActiveSupport::Deprecation.warn("Using the 'api' call has no longer effect. Define endpoints instead.", caller)
      end

      protected

      # Registers an endpoint
      def register_endpoint(ep, options)
        current_endpoints = read_inheritable_attribute(:endpoints) || {}
        current_endpoints.merge!(ep => options)
        write_inheritable_attribute(:endpoints, current_endpoints)
      end

    end

    # Invokes endpoint calls
    # +endpoint+ may contain the path to the endpoint in a component down the hierarchy, e.g.:
    #
    #     invoke_endpoint(:users__center__get_data, params)
    def invoke_endpoint(endpoint, params)
      ep_config = self.class.endpoints[endpoint.to_sym]

      if respond_to?("_#{endpoint}_ep_wrapper")
        # we have this endpoint defined
        send("_#{endpoint}_ep_wrapper", params)
      elsif respond_to?(endpoint)
        # for backward compatibility
        ::ActiveSupport::Deprecation.warn("When overriding endpoints, use the '_endpoint' suffix (concerns: #{endpoint})", caller)
        send(endpoint, params)
      elsif respond_to?(endpoint + "_endpoint")
        # for backward compatibility
        send(endpoint + "_endpoint", params)
      else
        # Let's try to find it recursively in a component down the hierarchy
        child_component, *action = endpoint.to_s.split('__')
        child_component = child_component.to_sym
        action = !action.empty? && action.join("__").to_sym

        raise RuntimeError, "Component '#{self.class.name}' does not have endpoint '#{endpoint}'" if !action

        if components[child_component]
          component_instance(child_component).invoke_endpoint(action, params)
        else
          # component_missing can be overridden if necessary
          component_missing(child_component)
        end
      end
    end

  end
end