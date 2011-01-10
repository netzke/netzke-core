require 'active_support/core_ext/hash/indifferent_access'
module Netzke
  # When a persistence subsystem (such as {netzke-persistence}[https://github.com/skozlov/netzke-persistence]) is used, a widget can store its state using the +update_state+ method that accepts a hash, e.g.:
  #     update_state(:position => {:x => 100, :y => 200})
  #
  # Later the state can be retrieved by calling the +state+ method:
  #
  #     state[:position] #=> {:x => 100, :y => 200}
  #
  # To enable persistence for a specific component, configure it with +persistence+ option set to +true+.
  #
  # == Sharing state
  #
  # Different components can share the state by sharing the persistence key, which can be provided as configuration option, e.g.:
  #
  #     netzke :books, :class_name => "Basepack::GridPanel", :persistence_key => "books_state_identifier"
  #     netzke :deleted_books, :class_name => "Basepack::GridPanel", :persistence_key => "books_state_identifier"
  #
  # Make sure that the provided persistence_key has effect on _application_ level, _not_ only within the view.
  # By default persistence_key is set to component's global id. Thus, <i>two components named equally will share the state even being used in different views</i>.
  #
  module State
    # A string which will identify the component in persistence subsystem.
    # If +persistence_key+ is passed, use it. Otherwise use global_id.
    def persistence_key
      initial_config[:persistence_key] ? initial_config[:persistence_key] : global_id
    end

    # Component's persistent state.
    def state
      @state ||= (state_manager.state || {}).symbolize_keys
    end

    # Merges passed hash into component's state.
    # Can also accept 2 arguments which will be treated as a hash pair. E.g.:
    #
    #     update_state(:peoples_most_feared_number, 13)
    #
    # is equivalent to:
    #
    #     update_state(:peoples_most_feared_number => 13)
    def update_state(*args)
      state_manager.update_state!(args.first.is_a?(Hash) ? args.first : {args.first => args.last})
      @state = nil # reset cache
    end

    # Component's persistent state.
    def global_state
      @global_state ||= (global_state_manager.state || {}).symbolize_keys
    end

    # Merges passed hash into component's state.
    def update_global_state(hsh)
      global_state_manager.update_state!(hsh)
      @global_state = nil # reset cache
    end

    # Options merged into component's configuration right after default and user-passed config, thus being reflected in +Netzke::Base#independent_config+ (see Netzke::Configuration).
    def persistent_options
      (state[:persistent_options] || {}).symbolize_keys
    end

    # Updates +persistent_options+
    def update_persistent_options(hsh)
      new_persistent_options = persistent_options.merge(hsh)
      new_persistent_options.delete_if{ |k,v| v.nil? } # setting values to nil means deleting them
      update_state(:persistent_options => new_persistent_options)
    end

    protected

    # Initialized state manager class. At this moment this class has current_user, component, and session set.
    def state_manager
      @state_manager ||= Netzke::Core.persistence_manager_class.init({
        :component => persistence_key,
        :current_user => Netzke::Core.controller.respond_to?(:current_user) && Netzke::Core.controller.current_user,
        :session => Netzke::Core.session
      })
    end

    # Initialized state manager class, configured for managing global (not component specific) settings. At this moment this class has current_user and session set.
    def global_state_manager
      @global_state_manager ||= Netzke::Core.persistence_manager_class.init({
        :current_user => Netzke::Core.controller.respond_to?(:current_user) && Netzke::Core.controller.current_user,
        :session => Netzke::Core.session
      })
    end


  end
end
