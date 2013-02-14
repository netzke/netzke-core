module Netzke::Core
  # Implements component-specific session manupulation.
  module Session
    # Instance of this class is returned through component_session, and allows writing/reading to/from the session part reserved for a specific component (specified by component's js_id).
    class ComponentSessionProxy < Object
      def initialize(component_id)
        @session = Netzke::Base.session.nil? ? {} : Netzke::Base.session[component_id] ||= {}
      end

      # Delegate everything to session
      def method_missing(method, *args)
        @session.send(method, *args)
      end
    end

    # Component-specific session.
    def component_session
      @component_session_proxy ||= ComponentSessionProxy.new(js_id)
    end
  end
end
