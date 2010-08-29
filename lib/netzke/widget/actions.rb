module Netzke
  module Widget
    module Actions
      module ClassMethods
        def include_js_with_actions
          include_js_without_actions + ["#{File.dirname(__FILE__)}/actions.js"]
        end
      end
      
      module InstanceMethods
        def actions
          bar_items = (config[:bbar] || []) + (config[:tbar] || []) + (config[:fbar] || [])
          bar_items.uniq!
          collect_actions(bar_items)
        end
        
        def js_config_with_actions
          js_config_without_actions.merge(:actions => actions)
        end
        
        private
          # Extract action names from menus and toolbars.
          # E.g.: 
          # collect_actions(["->", {:text => "Menu", :menu => [{:text => "Submenu", :menu => [:another_button]}, "-", :a_button]}])
          #  => {:a_button => {:text => "A button"}, :another_button => {:text => "Another button"}}
          def collect_actions(arry)
            res = {}
            arry.each do |item|
              if item.is_a?(Hash) && menu = item[:menu]
                res.merge!(collect_actions(item[:menu]))
              elsif item.is_a?(Symbol)
                # it's an action
                res.merge!(item => {:text => item.to_s.humanize})
              elsif item.is_a?(String)
                # it's a string item (or maybe JS code)
              else
              end
            end
            res
          end
        
      end
      
      def self.included(receiver)
        receiver.extend         ClassMethods
        receiver.send :include, InstanceMethods
        receiver.alias_method_chain :js_config, :actions
        receiver.js_alias_method_chain :init_component, :actions

        receiver.write_inheritable_attribute(:js_before_constructor,
          <<-END_OF_JAVASCRIPT << (receiver.read_inheritable_attribute(:js_before_constructor) || ""))
Ext.apply(this, Netzke.modules.Actions);
          END_OF_JAVASCRIPT
        
        class << receiver
          alias_method_chain :include_js, :actions
        end
        
      end
    end
  end
end