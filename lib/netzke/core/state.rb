module Netzke::Core
  # A component can store its state using the +update_state+ method that accepts a hash, e.g.:
  #
  #     update_state(:position => {:x => 100, :y => 200})
  #
  # Later the state can be retrieved by calling the +state+ method:
  #
  #     state[:position] #=> {:x => 100, :y => 200}
  #
  # To enable persistence for a specific component, configure it with +persistence+ option set to +true+.
  # Default implementation uses session, but can be implemented differently by other gems (see netzke-persistence for an example).
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
    #     state[:title]
    #
    # Can be overridden by persistence subsystems.
    def state
      session[:state] ||= {}
      session[:state][persistence_key] ||= {}
    end

    # Accepts 2 arguments which will be treated as a hash pair. E.g.:
    #
    #     update_state :request_counter, 3
    #
    # Can be overridden by persistence subsystems.
    def update_state(*args)
      state[args.first.to_sym] = args.last
    end

    def clear_state
      state.clear
    end
  end
end
