module Netzke
  class WidgetThatHasActions < Widget::Base
    
    include Widget::Actions
    
    def default_config
      super.merge(
        :bbar => [js_action(:some_action), js_action(:another_action)],
        :tbar => [{
          :xtype =>  'buttongroup',
          :columns => 3,
          :title => 'Clipboard',
          :items => [{
              :text => 'Paste',
              :scale => 'large',
              :rowspan => 3, :iconCls => 'add',
              :iconAlign => 'top',
              :cls => 'x-btn-as-arrow'
          },{
              :xtype => 'splitbutton',
              :text => 'Menu Button',
              :scale => 'large',
              :rowspan => 3,
              :iconCls => 'add',
              :iconAlign => 'top',
              :arrowAlign => 'bottom',
              :menu => [js_action(:some_action)]
          },{
              :xtype => 'splitbutton', :text => 'Cut', :menu => [js_action(:another_action)]
          }, js_action(:another_action), 
          {
              :menu => [js_action(:some_action)], :text => 'Format'
          }]
        }]
      )
    end
    
    def actions
      super.deep_merge({
        :some_action => {:text => "Some action"},
        :another_action => {:disabled => true, :text => "Disabled action"}
      })
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