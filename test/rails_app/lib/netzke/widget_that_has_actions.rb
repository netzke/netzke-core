module Netzke
  class WidgetThatHasActions < Widget::Panel
    
    def default_config
      super.merge(
        :bbar => [:some_action],
        :tbar => [:another_action]
      )
    end
    
    def actions
      super.deep_merge(
        :another_action => {:disabled => true, :text => "Disabled action"}
      )
    end
    
    def self.js_properties
      {
        :title => "Panel that has actions",
        
        :on_some_action => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.update("Some action was triggered");
          }
        END_OF_JAVASCRIPT
        
        :on_another_action => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.update("Another action was triggered");
          }
        END_OF_JAVASCRIPT
        
      }
    end
    
  end
end