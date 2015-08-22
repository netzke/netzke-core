module Netzke::Core
  # The client-server communication between the JavaScript and Ruby side of a component is provided by means of "endpoints".
  #
  # == Defining an endpoint
  #
  # An endpoint is defined through the +endpoint+ class method on the Ruby class:
  #
  #     endpoint :do_something do
  #       # ...
  #     end
  #
  # The first block argument will contain the hash of arguments provided at the moment of calling the endpoint from the JavaScript side (see "Calling an endpoint from JavaScript").
  # The second block argument is used for "calling" JavaScript methods as a response from the server (see "Envoking JavaScript methods from the server").
  #
  # == Calling an endpoint from JavaScript
  #
  # By defining the endpoint on the Ruby class, the client side automatically gets an equally named (in camelCase) function that is used to call the endpoint. In the previous example, that would be +doSomething+. Its signature goes as follows:
  #
  #     this.doSomething(args..., callback, scope);
  #
  # * +args+ (optional) is what the +endpoint+ block at the server will receive as parameters
  # * +callback+ (optional) will be called after the server successfully processes the request
  # * +scope+ (optional) the scope in which +callback+ will be called, defaults to component instance
  #
  # The callback function can optionally receive an argument set by the endpoint at the server (see "Providing the argument to the callback function").
  #
  # == Envoking JavaScript methods from the server
  #
  # An endpoint, after doing some useful job at the server, is able to instruct the client side of the component to call multiple methods (preserving the call order) with provided arguments. It's done via using the magic `this` method:
  #
  #     endpoint :do_something do
  #       # ... do the thing
  #       this.set_title("New title")
  #       this.add_class("some-extra-css")
  #     end
  #
  # This will result in successive calling the +setTitle+ and +addClass+ methods on the JavaScript instance of the component.
  #
  # Besides "calling" methods on the current component itself, it's also possible to address its instantiated children at any level of the hierarchy:
  #
  #     endpoint :do_something do
  #       # ... do the thing
  #       this.east_panel_component.set_title("New east panel title")
  #       this.east_panel_component.deep_nested_component.do_something_very_special("With", "some", "arguments")
  #     end
  #
  # == Providing arguments to the callback function
  #
  # The callback function provided at the moment of calling an endpoint will receive as its only argument the result of
  # the `endpoint` block execution:
  #
  #     endpoint :get_the_answer do
  #       # ... do the thing
  #       42
  #     end
  #
  # By calling the endpoint from the client side like this:
  #
  #     this.getTheAnswer(function(result){ console.debug(result); });
  #
  # ... the value of +result+ after the execution of the endpoint will be set to 42. Using this mechanism can be seen as doing an asyncronous call to a server-side function that returns a value.
  #
  # == Overriding an endpoint
  #
  # When overriding an endpoint, you can call the original endpoint by using +super+ and explicitely providing the block parameters to it:
  #
  #     endpoint :do_something do |params|
  #       super(params)
  #       this.doMore
  #     end
  #
  # If you want to reuse the original arguments set in +super+, you can access them from the +this+ object. Provided we are overriding the +do_something+ endpoint from the example in "Envoking JavaScript methods from the server", we will have:
  #
  #     endpoint :do_something do |params|
  #       super(params)
  #       original_arguments_for_set_title = this.set_title # => ["New title"]
  #       original_arguments_for_add_class = this.add_class # => ["some-extra-css"]
  #     end
  module Services
    extend ActiveSupport::Concern

    included do
      # Returns all endpoints as a hash
      class_attribute :endpoints
      self.endpoints = {}

      # instance of EndpointResponse
      attr_accessor :this
    end

    module ClassMethods
      def endpoint(name, options = {}, &block)
        register_endpoint(name)
        define_method("#{name}_endpoint", &block)
      end

    protected

      # Registers an endpoint at the class level
      def register_endpoint(ep)
        self.endpoints = self.endpoints.dup if self.superclass.respond_to?(:endpoints) && self.endpoints == self.superclass.endpoints #  only dup for the first endpoint declaration
        self.endpoints[ep.to_sym] = true
      end
    end

    # Invokes an endpoint
    #
    # +endpoint+ may contain the path to the endpoint in a component down the hierarchy, e.g.:
    # +params+ contains an Array of parameters to pass to the endpoint
    #
    #     invoke_endpoint(:users__center__get_data, params)
    #
    # Returns instance of EndpointResponse
    def invoke_endpoint(endpoint, params, configs = [])
      self.this = Netzke::Core::EndpointResponse.new

      if has_endpoint?(endpoint)
        this.netzke_set_result(send("#{endpoint}_endpoint", *params))
        this
      else
        # Let's try to find it recursively in a component down the hierarchy
        child_component, *action = endpoint.to_s.split('__')
        action = !action.empty? && action.join("__").to_sym

        return unknown_endpoint_exception(endpoint) if !action
        return unknown_component_exception(child_component) if components[child_component.to_sym].nil?

        client_config = configs.shift || {}
        js_id = client_config.delete("component_id")
        cmp_strong_config = {client_config: client_config, js_id: js_id}

        # recursive
        component_instance(child_component.to_sym, cmp_strong_config).invoke_endpoint(action, params, configs)
      end
    end

    def unknown_endpoint_exception(endpoint)
      this.netzke_set_result(error: {
        type: "UNKNOWN_ENDPOINT",
        msg: "Component '#{self.class.name}' does not have endpoint '#{endpoint}'"
      })

      this
    end

    def unknown_component_exception(component)
      this.netzke_set_result(error: {
        type: "UNKNOWN_COMPONENT",
        msg: "Component '#{self.class.name}' does not have component '#{component}'"
      })

      this
    end

    def has_endpoint?(endpoint)
      !!self.class.endpoints[endpoint.to_sym]
    end

    # Called when the method_missing tries to processes a non-existing component. Override when needed.
    # Note: this should actually never happen unless you mess up with Netzke component loading mechanisms.
    def component_missing(missing_component, *params)
      this.netzke_feedback "Unknown component '#{missing_component}' in '#{name}'"
    end
  end
end
