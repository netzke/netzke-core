module Netzke
  module Core
    module Session
      # Should be called by session controller at the moment of successfull login
      def login
        session[:_netzke_next_request_is_first_after_login] = true
      end

      # Should be called by session controller at the moment of logout
      def logout
        session[:_netzke_next_request_is_first_after_logout] = true
      end

      # Register the configuration for the component in the session, and also remember that the code for it has been rendered
      def reg_component(config)
        session[:netzke_components] ||= {}
        session[:netzke_components][config[:name]] = config
      end
    end
  end
end