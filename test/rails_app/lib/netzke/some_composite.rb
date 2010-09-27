module Netzke
  class SomeComposite < Component::Base
    def config
      {
        # 2 different ways to embed an component
        :items => [
          # 1 - from the +components+ method
          js_component(:center_panel, :region => 'center'),
          
          # 2 - inline (will be conerted into an component accessible with the +component+ method)
          {:name => "west_panel", :class_name => "ExtendedServerCaller", :region => 'west', :width => 300, :split => true},
          
          js_component(:east_panel, :region => :east, :width => 500, :split => true)
        ],
        :bbar => [:update_west_panel.ext_action, :update_center_panel.ext_action, :update_west_from_server.ext_action, :update_east_south_from_server.ext_action]
      }.deep_merge super
    end
    
    def components
      super.merge(
        :center_panel => {
          :class_name => "ServerCaller"
        },
        
        :east_panel => {:class_name => "BorderLayoutPanel", :items => [{
            :name => :center_panel,
            :class_name => "SimplePanel",
            :title => "A panel",
            :region => :center
          },{
            :class_name => "SimplePanel",
            # :name => :south_panel,
            :region => :south,
            :title => "Another panel",
            :height => 200,
            :split => true
        }]}
      )
    end
    
    api :update_east_south
    def update_east_south(params)
      {:east_panel => {:simple_panel1 => {:set_title => "Here's an update for south panel in east panel"}}}
    end
    
    api :update_west
    def update_west(params)
      {:west_panel => {:set_title => "Here's an update for west panel"}}
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
        
        :on_update_east_south_from_server => <<-JS.l,
          function(){
            this.updateEastSouth();
          }
        JS
        
        :on_update_west_from_server => <<-JS.l
          function(){
            this.updateWest();
          }
        JS
      }
    end
  end
end