module Netzke
  module Core
    module Session
      # Register the configuration for the component in the session
      def reg_component(config)
        session[:netzke_components] ||= {}
        session[:netzke_components][config[:name]] = config
      end
    end
  end
end
