module Netzke
  module Session
    module ClassMethods
      # Access to controller sessions
      def session
        @@session ||= {}
      end

      def session=(s)
        @@session = s
      end

      # Should be called by session controller at the moment of successfull login
      def login
        session[:_netzke_next_request_is_first_after_login] = true
      end
    
      # Should be called by session controller at the moment of logout
      def logout
        session[:_netzke_next_request_is_first_after_logout] = true
      end

      # Register the configuration for the widget in the session, and also remember that the code for it has been rendered
      def reg_widget(config)
        session[:netzke_widgets] ||= {}
        session[:netzke_widgets][config[:name]] = config
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