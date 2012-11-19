module Netzke::Core
  # Implements component-specific session manupulation.
  module Session
    class ComponentSessionProxy < Hash #:nodoc:
      def initialize(component_id)
        @component_id = component_id
        super
      end

      def [](key)
        component_session[key]
      end

      def []=(key, value)
        component_session.try(:store, key, value)
      end

      def clear
        component_session.try(:clear)
      end

      def merge!(hsh)
        component_session.try(:merge!, hsh)
      end

    protected

      def component_session
        Netzke::Base.session[@component_id] ||= {}
      end
    end

    # Component-specific session.
    def component_session
      @component_session_proxy ||= ComponentSessionProxy.new(js_id)
    end
  end
end
