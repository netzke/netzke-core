module Netzke
  module Component
    # This modules provides (component-specific) session manupulation.
    # The :session_persistence config option should be set to true in order for the component to make use of this.
    module Session
      # Top-level session (straight from the controller).
      def session
        ::Netzke::Main.session
      end
    
      # Component-specific session.
      def component_session
        session[global_id] ||= {}
      end
      
      # Returns this component's configuration options stored in the session. Those get merged into the component's configuration at instantiation.
      def session_options
        session_persistence_enabled? && component_session[:options] || {}
      end
   
      # Updates the session options
      def update_session_options(hash)
        if session_persistence_enabled?
          component_session[:options] ||= {}
          component_session[:options].merge!(hash)
        else
          logger.debug "Netzke warning: No session persistence enabled for component '#{global_id}'"
        end
      end
      
      private
        def session_persistence_enabled?
          initial_config[:session_persistence]
        end
    end
  end
end