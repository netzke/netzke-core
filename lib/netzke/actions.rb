module Netzke
  # Netzke component allows specifying "actions" in Ext-style.
  # Override the +actions+ method in your sub-class to define the actions like this:
  # 
  #    def actions
  #      super.deep_merge(
  #        :some_action => {:text => "Some action"},
  #        :another_action => {:disabled => true, :text => "Disabled action", :icon_cls => "my-fancy-icon"}
  #      )
  #    end
  #
  # Then use them in the config in arbitrary places, using the +action+ method on symbols, e.g.:
  # 
  #    def config
  #      {
  #        :bbar => [:some_action.action, :another_action.action],
  #        :tbar => [{
  #          :xtype =>  'buttongroup',
  #          :columns => 3,
  #          :title => 'Clipboard',
  #          :items => [{
  #              :text => 'Paste',
  #              :scale => 'large',
  #              :rowspan => 3, :iconCls => 'add',
  #              :iconAlign => 'top',
  #              :cls => 'x-btn-as-arrow'
  #          },{
  #              :xtype => 'splitbutton',
  #              :text => 'Menu Button',
  #              :scale => 'large',
  #              :rowspan => 3,
  #              :iconCls => 'add',
  #              :iconAlign => 'top',
  #              :arrowAlign => 'bottom',
  #              :menu => [:some_action.action]
  #          },{
  #              :xtype => 'splitbutton', :text => 'Cut', :menu => [:another_action.action]
  #          }, :another_action.action,
  #          {
  #              :menu => [:some_action.action], :text => 'Format'
  #          }]
  #        }]
  #      }.deep_merge super
  #    end
  module Actions
    module ClassMethods
      def action(name, config)
        current_actions = read_clean_inheritable_hash(:actions)
        current_actions.merge!(name => config)
        write_inheritable_attribute(:actions, current_actions)
      end
      
      def extract_actions(hsh)
        hsh.each_pair.inject({}) do |r,(k,v)| 
          v.is_a?(Array) ? r.merge(extract_actions_from_array(v)) : r
        end
      end
      
      def extract_actions_from_array(arry)
        arry.inject({}) do |r, el|
          if el.is_a?(Hash)
            el[:action] ? r.merge(el[:action] => auto_action_config(el[:action])) : r.merge(extract_actions(el))
          else
            r
          end
        end
      end
      
      def auto_action_config(action_name)
        {:text => action_name.to_s.humanize}
      end
    end
    
    module InstanceMethods
      
      # Actions to be used in the config
      def actions
        self.class.extract_actions(config).merge(self.class.read_clean_inheritable_hash(:actions) || {})
      end

      def js_config_with_actions #:nodoc
        actions.empty? ? js_config_without_actions : js_config_without_actions.merge(:actions => actions)
      end
      
    end
    
    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
      receiver.alias_method_chain :js_config, :actions
    end
  end
end