module Netzke
  module Configuration
    extend ActiveSupport::Concern

    CONFIGURATION_LEVELS = [:default, :initial, :independent, :session, :final]

    included do
      CONFIGURATION_LEVELS.each do |level|
        define_method("weak_#{level}_options"){ {} }
      end
    end

    module ClassMethods
      def setup
        yield self
      end

      # Config options that should not go to the client side
      def server_side_config_options
        [:lazy_loading, :class_name]
      end

      def config(*args, &block)
        level = args.first.is_a?(Symbol) ? args.first : :final
        config_hash = args.last.is_a?(Hash) && args.last
        raise ArgumentError, "Config hash or block required" if !block_given? && !config_hash
        if block_given?
          define_method(:"weak_#{level}_options", &block)
        else
          define_method(:"weak_#{level}_options") do
            config_hash
          end
        end
      end

    end

    module InstanceMethods
      # Default config - before applying any passed configuration
      def default_config
        @default_config ||= {}.merge(weak_default_options).merge(self.class.default_instance_config)
      end

      # Static, hardcoded config. Consists of default values merged with config that was passed during instantiation
      def initial_config
        @initial_config ||= default_config.merge(weak_initial_options).merge(@passed_config)
      end

      # Config that is not overridden by parents and sessions
      def independent_config
        @independent_config ||= initial_config.merge(weak_independent_options).merge(persistence_enabled? ? persistent_options : {})
      end

      def session_config
        @session_config ||= independent_config.merge(weak_session_options).merge(session_options)
      end

      # Last level config, overridden only by ineritance
      def final_config
        @strong_config ||= session_config.merge(weak_final_options).merge(strong_parent_config)
      end

      # Resulting config that takes into account all possible ways to configure a component. *Read only*.
      # Translates into something like this:
      #
      #     default_config.
      #     deep_merge(@passed_config).
      #     deep_merge(persistent_options).
      #     deep_merge(strong_parent_config).
      #     deep_merge(strong_session_config)
      #
      # Moved out to a separate method in order to provide for easy caching.
      # *Do not override this method*, use +Base.config+ instead.
      def config
        @config ||= final_config
      end

      def flat_config(key = nil)
        fc = config.flatten_with_type
        key.nil? ? fc : fc.select{ |c| c[:name] == key.to_sym }.first.try(:value)
      end

      def strong_parent_config
        @strong_parent_config ||= parent.nil? ? {} : parent.strong_children_config
      end

      def flat_independent_config(key = nil)
        fc = independent_config.flatten_with_type
        key.nil? ? fc : fc.select{ |c| c[:name] == key.to_sym }.first.try(:value)
      end

      def flat_default_config(key = nil)
        fc = default_config.flatten_with_type
        key.nil? ? fc : fc.select{ |c| c[:name] == key.to_sym }.first.try(:value)
      end

      def flat_initial_config(key = nil)
        fc = initial_config.flatten_with_type
        key.nil? ? fc : fc.select{ |c| c[:name] == key.to_sym }.first.try(:value)
      end

      # Like normal config, but stored in session
      # def weak_session_config
      #   component_session[:weak_session_config] ||= {}
      # end
      #
      # def strong_session_config
      #   component_session[:strong_session_config] ||= {}
      # end



      # configuration of all children will get deep_merge'd with strong_children_config
      # def strong_children_config= (c)
      #   @strong_children_config = c
      # end

      # This config will be picked up by all the descendants
      def strong_children_config
        @strong_children_config ||= parent.nil? ? {} : parent.strong_children_config
      end

      # configuration of all children will get reverse_deep_merge'd with weak_children_config
      # def weak_children_config= (c)
      #   @weak_children_config = c
      # end

      def weak_children_config
        @weak_children_config ||= {}
      end

    end
  end
end