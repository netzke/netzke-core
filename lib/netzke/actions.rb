module Netzke
  # Netzke component allows specifying Ext actions.
  # An action can be defined in 2 different ways, both of which result in a method definition like this 
  #     def _<some_action>_action
  #       ...
  #     end
  # 
  # The 2 ways to define an action are:
  # * as a hash:
  #     action :bug_server, :text => "Call server", :icon => "/images/icons/phone.png"  
  # 
  # * as a block:
  #     action :bug_server do
  #       {:text => config[:text], :disabled => true}
  #     end
  # 
  # The block can optionally receive the configuration of an action being overridden:
  #     action :bug_server do |orig|
  #       {:text => config[:text] + orig[:text], :disabled => orig[:disabled]}
  #     end
  module Actions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :js_config, :actions
    end
    
    module ClassMethods
      def action(name, config = {}, &block)
        config[:name] = name.to_s
        method_name = action_method_name(name)
        
        if block_given?
          if superclass.instance_methods.map(&:to_s).include?(method_name)
            define_method(method_name) do
              normalize_action_config(super().merge(yield(super())))
            end
          else
            define_method(method_name) do
              normalize_action_config(yield)
            end
          end
        else
          if superclass.instance_methods.map(&:to_s).include?(method_name)
            define_method(method_name) do
              normalize_action_config(super().merge(config))
            end
          else
            define_method(method_name) do
              normalize_action_config(config)
            end
          end
        end
      end
      
      def action_method_name(action)
        "_#{action}_action"
      end
    end
    
    # Actions to be used in the config
    def actions
      # Call all the action related methods to collect the actions
      action_method_regexp = /^_(.+)_action$/
      self.class.instance_methods.grep(action_method_regexp).inject({}) do |r, m|
        m.match(action_method_regexp)
        r.merge($1.to_sym => send(m))
      end
    end

    def js_config_with_actions #:nodoc
      actions.empty? ? js_config_without_actions : js_config_without_actions.merge(:actions => actions)
    end
    
    private
      def normalize_action_config(config)
        if config[:icon].is_a?(Symbol)
          config[:icon] = Netzke::Core.with_icons ? Netzke::Core.icons_uri + "/" + config[:icon].to_s + ".png" : nil
        end
        
        config[:text] ||= config[:name].humanize
        
        config
      end
  end
end