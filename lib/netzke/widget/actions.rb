module Netzke
  module Widget
    # Netzke widget allows specifying "actions" in Ext-style.
    # Override the +actions+ method in your sub-class to define the actions like this:
    # 
    #    def actions
    #      super.deep_merge(
    #        :some_action => {:text => "Some action"},
    #        :another_action => {:disabled => true, :text => "Disabled action", :icon_cls => "my-fancy-icon"}
    #      )
    #    end
    #
    # Then use them in the config in arbitrary places, using the +js_action+ method, e.g.:
    # 
    #    def default_config
    #      super.merge(
    #        :bbar => [js_action(:some_action), js_action(:another_action)],
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
    #              :menu => [js_action(:some_action)]
    #          },{
    #              :xtype => 'splitbutton', :text => 'Cut', :menu => [js_action(:another_action)]
    #          }, js_action(:another_action), 
    #          {
    #              :menu => [js_action(:some_action)], :text => 'Format'
    #          }]
    #        }]
    #      )
    #    end
    module Actions
      module ClassMethods
      end
      
      module InstanceMethods
        
        # Actions to be used in the config
        def actions
          @auto_actions || {}
        end

        def js_config_with_actions #:nodoc
          js_config_without_actions.merge(:actions => actions)
        end
        
        private
        
          # Returns a config hash that is detected at JS side as an action.
          # Also creates a default action config (for the case when this action is not defined in the +actions+ method).
          def js_action(action_name)
            @auto_actions ||= {}
            @auto_actions.merge!(auto_action_config(action_name))
            {:action => action_name}
          end
        
          def auto_action_config(action_name)
            {action_name => {:text => action_name.to_s.humanize}}
          end
        
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.alias_method_chain :js_config, :actions
      end
    end
  end
end