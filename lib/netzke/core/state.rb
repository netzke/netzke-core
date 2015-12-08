module Netzke::Core
  # A component can access and update its state through the +state+ method, e.g.:
  #
  #     state[:position] = {:x => 100, :y => 200}
  #
  #     state[:position] #=> {:x => 100, :y => 200}
  #
  # Default implementation uses session to store stateful data, but can be implemented differently by 3rd-party gems.
  #
  # == Sharing state
  #
  # Different components can share the state by specifying the same +persistent_key+ option.
  #
  # Note that the provided persistence_key has effect on _application_ level, _not_ only within the view.
  # By default +persistence_key+ is set to component's +js_id+. Thus, _two components named equally will share the state even being used in different Rails views_.
  module State
    class StateProxy
      def initialize(key)
        @key = key.to_s
        Netzke::Base.session ||= {}
        Netzke::Base.session[:netzke_states] ||= {}
      end

      # Delegate everything to session
      def method_missing(method, *args)
        session_data = to_hash
        session_data.send(method, *args).tap do |d|
          Netzke::Base.session[:netzke_states] = state_session.merge(@key => session_data)
        end
      end

      def to_hash
        ActiveSupport::HashWithIndifferentAccess.new(state_session[@key] || {})
      end

      def clear
        state_session.delete(@key)
      end

      private

      def state_session
        Netzke::Base.session[:netzke_states]
      end
    end
    # A string which identifies the component. Can be passed as +persistence_key+ config option. Two components with the same +persistence_key+ will be sharing the state.
    # If +persistence_key+ is passed in the config, use it. Otherwise use js_id.
    def persistence_key
      (config.persistence_key || js_id).to_sym
    end

    # Component's persistent state.
    #
    #     state[:position] = {:x => 100, :y => 200}
    #
    #     state[:position] #=> {:x => 100, :y => 200}
    #
    # May be overridden by persistence subsystems. The object returned by this should implement the following methods:
    #
    # * []
    # * []=
    # * delete(key)
    # * clear
    def state
      @state_proxy ||= StateProxy.new(persistence_key)
    end
  end
end
