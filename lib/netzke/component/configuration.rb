module Netzke
  module Component
    module Configuration
      module ClassMethods
        # Override class-level defaults specified in <tt>Netzke::Base.config</tt>. 
        # E.g. in config/initializers/netzke-config.rb:
        # 
        #     Netzke::Component::GridPanel.configure :default_config => {:persistent_config => true}
        def configure(*args)
          if args.first.is_a?(Symbol)
            config[args.first] = args.last
          else
            # first arg is hash
            config.deep_merge!(args.first)
          end
      
          # component may implement some kind of control for configuration consistency
          enforce_config_consistency if respond_to?(:enforce_config_consistency)
        end
    
    
        # Class-level Netzke::Base configuration. The defaults also get specified here.
        def config
          set_default_config({
            # Which javascripts and stylesheets must get included at the initial load (see netzke-core.rb)
            :javascripts               => [],
            :stylesheets               => [],

            :external_css              => [],

            # AR model that provides us with persistent config functionality
            :persistent_config_manager => "NetzkePreference",

            # Default location of extjs library
            :ext_location              => defined?(Rails) && Rails.root.join("public", "extjs"),
          })
        end

        def set_default_config(c) #:nodoc:
          @@config ||= {}
          @@config[self.name] ||= c
        end

        # Config options that should not go to the client side
        def server_side_config_options
          [:lazy_loading]
        end
    
      end
    
      module InstanceMethods
        # Default config - before applying any passed configuration
        def default_config
          self.class.config[:default_config].nil? ? {} : {}.merge(self.class.config[:default_config])
        end

        # Static, hardcoded config. Consists of default values merged with config that was passed during instantiation
        def initial_config
          @initial_config ||= default_config.deep_merge(@passed_config)
        end

        # Config that is not overwritten by parents and sessions
        def independent_config
          @independent_config ||= initial_config.deep_merge(persistent_options)
        end

        # Resulting config that takes into account all possible ways to configure a component. *Read only*.
        # Translates into something like this:
        #     default_config.
        #     deep_merge(@passed_config).
        #     deep_merge(persistent_options).
        #     deep_merge(strong_parent_config).
        #     deep_merge(strong_session_config)
        def config
          @config ||= independent_config.deep_merge(strong_parent_config).deep_merge(strong_session_config)
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
        def weak_session_config
          component_session[:weak_session_config] ||= {}
        end

        def strong_session_config
          component_session[:strong_session_config] ||= {}
        end

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
    
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
      end
    end
  end
end