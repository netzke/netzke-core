module Netzke
  class StaticAggregator < Widget::Base
    def config
      {
        # 2 different ways to embed an aggregatee
        :items => [
          # 1 - from the +aggregatees+ method
          js_aggregatee(:center_panel, :region => 'center'),
          
          # 2 - inline (will be conerted into an aggregatee accessible with the +aggregatee+ method)
          {:name => :west_panel, :class_name => "ExtendedServerCaller", :region => 'west', :width => 300, :split => true}
        ],
        :bbar => [:update_west_panel.ext_action, :update_center_panel.ext_action]
      }.deep_merge super
    end
    
    def aggregatees
      super.merge(
        :center_panel => {
          :class_name => "ServerCaller"
        }
      )
    end
    
    def self.js_properties
      {
        :title => "Static Aggregator",
        
        :layout => 'border',
        
        :on_update_west_panel => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.items.filter('name', 'west_panel').first().body.update('West Panel Body Updated');
          }
        END_OF_JAVASCRIPT
        
        :on_update_center_panel => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.items.filter('name', 'center_panel').first().body.update('Center Panel Body Updated');
          }
        END_OF_JAVASCRIPT
        
      }
    end
  end
end