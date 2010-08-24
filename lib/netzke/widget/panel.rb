module Netzke
  module Widget
    # Panel is a widget that supports automatic handling of actions. Later that functionality may be extracted to a separate module.
    class Panel < Base
      # Create default actions from bbar, tbar, and fbar, which are passed in the configuration
      def actions
        bar_items = (ext_config[:bbar] || []) + (ext_config[:tbar] || []) + (ext_config[:fbar] || [])
        bar_items.uniq!
        collect_actions(bar_items)
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
  end
end