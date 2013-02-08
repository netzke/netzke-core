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
    # A string which identifies the component. Can be passed as +persistence_key+ config option. Two components with the same +persistence_key+ will be sharing the state.
    # If +persistence_key+ is passed, use it. Otherwise use js_id.
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
      session[:netzke_states] ||= {}
      session[:netzke_states][persistence_key] ||= {}
    end
  end
end
