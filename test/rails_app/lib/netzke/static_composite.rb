module Netzke
  class StaticComposite < Component::Base
    def config
      {
        # 2 different ways to embed an component
        :items => [
          # 1 - from the +components+ method
          js_component(:center_panel, :region => 'center'),
          
          # 2 - inline (will be conerted into an component accessible with the +component+ method)
          {:name => :west_panel, :class_name => "ExtendedServerCaller", :region => 'west', :width => 300, :split => true}
        ],
        :bbar => [:update_west_panel.ext_action, :update_center_panel.ext_action]
      }.deep_merge super
    end
    
    def components
      super.merge(
        :center_panel => {
          :class_name => "ServerCaller"
        }
      )
    end
    
    def self.js_properties
      {
        :title => "Static Composite",
        
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