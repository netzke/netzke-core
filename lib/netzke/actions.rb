module Netzke
  # Netzke component allows specifying "actions" in Ext-style.
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
  #       {:text => config[:text], :disabled => super[:disabled]}
  #     end
  # 
  # Of course, you could also directly define a method, but is it really needed?
  module Actions
    extend ActiveSupport::Concern

    included do
      alias_method_chain :js_config, :actions
    end
    
    module ClassMethods
      def action(name, config = {}, &block)
        method_name = "_#{name}_action"
        if block_given?
          define_method(method_name, &block)
        else
          define_method(method_name) do
            config
          end
        end
      end
      
      def extract_actions(hsh)
        hsh.each_pair.inject({}) do |r,(k,v)| 
          v.is_a?(Array) ? r.merge(extract_actions_from_array(v)) : r
        end
      end
      
      def extract_actions_from_array(arry)
        arry.inject({}) do |r, el|
          if el.is_a?(Hash)
            el[:action] ? r.merge(el[:action] => default_action_config(el[:action])) : r.merge(extract_actions(el))
          else
            r
          end
        end
      end
      
      def default_action_config(action_name)
        {:text => action_name.to_s.humanize}
      end
    end
    
    module InstanceMethods
      
      # Actions to be used in the config
      def actions
        self.class.extract_actions(config).each_pair do |k,v|
          self.class.action(k, v)
        end
        
        # Call all the action related methods to collect the actions
        action_method_regexp = /^_(.+)_action$/
        methods.grep(action_method_regexp).inject({}) do |r, m|
          m.match(action_method_regexp)
          r.merge($1.to_sym => send(m))
        end
      end

      def js_config_with_actions #:nodoc
        actions.empty? ? js_config_without_actions : js_config_without_actions.merge(:actions => actions)
      end
      
    end
    
  end
end