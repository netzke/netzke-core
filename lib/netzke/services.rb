module Netzke
  module Services
    class BadEndpointReturnType < RuntimeError; end
    
    module ClassMethods
      # Declare connection points between client side of a component and its server side. For example:
      #
      #     api :reset_data
      # 
      # will provide JavaScript side with a method <tt>resetData</tt> that will result in a call to Ruby 
      # method <tt>reset_data</tt>, e.g.:
      # 
      #     this.resetData({hard:true});
      # 
      # See netzke-basepack's GridPanel for an example.
      # 
      def api(*api_points)
        ::ActiveSupport::Deprecation.warn("Using the 'api' call is deprecated. Use the 'endpoint' approach instead", caller)
        
        api_points.each do |apip|
          add_endpoint(apip)
        end
        
        # It may be needed later for security
        api_points.each do |apip|
          module_eval <<-END, __FILE__, __LINE__
          def endpoint_#{apip}(*args)
            before_api_call_result = defined?(before_api_call) && before_api_call('#{apip}', *args) || {}
            (before_api_call_result.empty? ? #{apip}(*args) : before_api_call_result).to_nifty_json
          end
          END
        end
      end

      # Defines an endpoint
      def endpoint(name, options = {}, &block)
        add_endpoint(name)
        define_method name, &block if block # if no block is given, the method is supposed to be defined elsewhere
          
        # define_method name, &block if block # if no block is given, the method is supposed to be defined elsewhere
        define_method :"endpoint_#{name}" do |*args|
          res = send(name, *args)
          res.respond_to?(:to_nifty_json) && res.to_nifty_json || ""
        end
      end
      
      # Register an endpoint
      def add_endpoint(ep)
        current_endpoints = read_inheritable_attribute(:endpoints) || []
        current_endpoints << ep
        write_inheritable_attribute(:endpoints, current_endpoints.uniq)
      end

      # Returns registered endpoints
      def endpoints
        read_inheritable_attribute(:endpoints)
      end
    end
    
    module InstanceMethods
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end