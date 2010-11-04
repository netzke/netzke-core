module Netzke
  # TODO:
  # rename persistence_ to persistence_
  module State
    # If the component has persistent config in its disposal
    # def persistence_enabled?
    #   !!(Netzke::Core.persistence_manager_class && initial_config[:persistence])
    # end

    # Access to the global persistent config (e.g. of another component)
    def global_persistent_config(owner = nil)
      config_class = Netzke::Core.persistence_manager_class
      config_class.component_name = owner
      config_class
    end

    # A string which will identify NetzkePreference records for this component.
    # If <tt>persistence_key</tt> is passed, use it. Otherwise use global component's id.
    def persistence_key #:nodoc:
      initial_config[:persistence_key] ? initial_config[:persistence_key] : global_id
    end

    def update_persistent_options(hash)
      options = persistent_options
      state_record(:persistent_config).update_attribute(:value, options.deep_merge(hash))
    end

    def persistent_options
      state_manager.state_to_read.try(:value).try(:fetch, :persistent_options, {}) || {}
    end

    def state_manager
      @@state_manager ||= Netzke::Core.persistence_manager_class.init({
        :component => persistence_key,
        :current_user => Netzke::Core.controller.respond_to?(:current_user) && Netzke::Core.controller.current_user,
        :session => Netzke::Core.session
      })
    end

    def update_state(hsh)
      state_manager.update_state!(hsh)
    end

    def state
      state_manager.state_to_read.try(:value) || {}
    end
  end
end