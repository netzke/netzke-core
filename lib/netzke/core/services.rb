module Netzke::Core
  # The client-server communication between the JavaScript and Ruby side of a component is provided by means of "endpoints".
  #
  # == Defining an endpoint
  #
  # An endpoint is defined through the +endpoint+ class method on the Ruby class:
  #
  #     endpoint :do_something do |params, this|
  #       # ...
  #     end
  #
  # The first block argument will contain the hash of arguments provided at the moment of calling the endpoint from the JavaScript side (see "Calling an endpoint from JavaScript").
  # The second block argument is used for "calling" JavaScript methods as a response from the server (see "Envoking JavaScript methods from the server").
  #
  # == Calling an endpoint from JavaScript
  #
  # By defining the endpoint on the Ruby class, the client side automatically gets an equally named (but camelcased) method that is used to call the endpoint at the server. In the previous example, that would be +doSomething+. Its signature goes as follows:
  #
  #     this.doSomething(argsObject, callbackFunction, scope);
  #
  # * +argsObject+ is what the server side will receive as the +params+ argument
  # * +callbackFunction+ (optional) will be called after the server successfully processes the request
  # * +scope+ (optional) the scope in which +callbackFunction+ will be called
  #
  # The callback function can optionally receive an argument set by the endpoint at the server (see "Providing the argument to the callback function").
  #
  # == Envoking JavaScript methods from the server
  #
  # An endpoint, after doing some useful job at the server, is able to instruct the client side of the component to call multiple methods (preserving the call order) with provided arguments. It's done by using the second parameter of the endpoint block (which is illustratively called 'this'):
  #
  #     endpoint :do_something do |params, this|
  #       # ... do the thing
  #       this.set_title("New title")
  #       this.add_class("some-extra-css")
  #     end
  #
  # This will result in successive calling the +setTitle+ and +addClass+ methods on the JavaScript instance of our component.
  #
  # Besides "calling" methods on the current component itself, it's also possible to address its instantiated children at any level of the hierarchy:
  #
  #     endpoint :do_something do |params, this|
  #       # ... do the thing
  #       this.east_panel_component.set_title("New east panel title")
  #       this.east_panel_component.deep_nested_component.do_something_very_special("With", "some", "arguments")
  #     end
  #
  # == Providing arguments to the callback function
  #
  # The callback function provided at the moment of calling an endpoint may receive an argument set by the endpoint by "calling" the special +netzke_set_result+ method. :
  #
  #     endpoint :do_something do |params, this|
  #       # ... do the thing
  #       this.netzke_set_result(42)
  #     end
  #
  # By calling the endpoint from the client side like this:
  #
  #     this.doSomething({}, function(result){ console.debug(result); });
  #
  # ... the value of +result+ after the execution of the endpoint will be set to 42. Using this mechanism can be seen as doing an asyncronous call to a function at the server, which returns a value.
  #
  # == Overriding an endpoint
  #
  # When overriding an endpoint, you can call the original endpoint by using +super+ and explicitely providing the block parameters to it:
  #
  #     endpoint :do_something do |params, this|
  #       super(params, this)
  #       this.doMore
  #     end
  #
  # If you want to reuse the original arguments set in +super+, you can access them from the +this+ object. Provided we are overriding the +do_something+ endpoint from the example in "Envoking JavaScript methods from the server", we will have:
  #
  #     endpoint :do_something do |params, this|
  #       super(params, this)
  #       original_arguments_for_set_title = this.set_title # => ["New title"]
  #       original_arguments_for_add_class = this.add_class # => ["some-extra-css"]
  #     end
  module Services
    extend ActiveSupport::Concern

    included do
       # Returns all endpoints as a hash
      class_attribute :endpoints
      self.endpoints = {}
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

    # Invokes an endpoint call
    # +endpoint+ may contain the path to the endpoint in a component down the hierarchy, e.g.:
    #
    #     invoke_endpoint(:users__center__get_data, params)
    def invoke_endpoint(endpoint, params)
      if self.class.endpoints[endpoint.to_sym]
        endpoint_response = Netzke::Core::EndpointResponse.new
        send("#{endpoint}_endpoint", params, endpoint_response)

        endpoint_response
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
