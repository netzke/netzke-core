module Netzke
  module Component
    module Api
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
          apip = read_inheritable_attribute(:api_points) || []
          api_points.each{|p| apip << p}
          write_inheritable_attribute(:api_points, apip)

          # It may be needed later for security
          api_points.each do |apip|
            module_eval <<-END, __FILE__, __LINE__
            def api_#{apip}(*args)
              before_api_call_result = defined?(before_api_call) && before_api_call('#{apip}', *args) || {}
              (before_api_call_result.empty? ? #{apip}(*args) : before_api_call_result).to_nifty_json
            end
            END
          end
        end

        # Array of API-points specified with <tt>Netzke::Base.api</tt> method
        def api_points
          read_inheritable_attribute(:api_points)
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
end