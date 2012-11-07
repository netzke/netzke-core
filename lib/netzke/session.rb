module Netzke
  # This modules provides (component-specific) session manupulation.
  # The :session_persistence config option should be set to true in order for the component to make use of this.
  module Session
    class ComponentSessionProxy < Hash #:nodoc:
      def initialize(component_id)
        @component_id = component_id
        super
      end

      def [](key)
        (Netzke::Base.session[@component_id] || {})[key]
      end

      def []=(key, value)
        (Netzke::Base.session[@component_id] ||= {})[key] = value
        # super
      end

      def clear
        Netzke::Base.session[@component_id].try(:clear)
      end

      def merge!(hsh)
        Netzke::Base.session[@component_id].try(:merge!, hsh)
      end
    end

    # Component-specific session.
    def component_session
      @component_session_proxy ||= ComponentSessionProxy.new(js_id)
    end
  end
end
