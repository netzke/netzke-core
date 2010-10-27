class SomeComposite < Netzke::Base
  js_properties :title => "Static Composite", 
                :layout => 'border',
                :bbar => [
                  :update_west_panel.action, 
                  :update_center_panel.action,
                  :update_west_from_server.action,
                  :update_east_south_from_server.action
                ]
  
  action :update_center_panel
  action :update_west_panel
  action :update_west_from_server
  action :update_east_south_from_server
  
  config :items => [
            :center_panel.component(:region => 'center'),
            :west_panel.component(:region => 'west', :width => 300, :split => true),
            {:layout => 'border', :region => :east, :width => 500, :split => true, :items => [
              :east_center_panel.component(:region => :center), 
              :east_south_panel.component(:region => :south, :height => 200, :split => true)
            ]},
          ]
  
  component :west_panel, :class_name => "ExtendedServerCaller"
  
  component :center_panel, :class_name => "ServerCaller"
  
  component :east_center_panel, :class_name => "SimpleComponent", :title => "A panel"
  
  component :east_south_panel, :class_name => "SimpleComponent", :title => "Another panel"
  
  endpoint :update_east_south do |params|
    {:east_south_panel => {:set_title => "Here's an update for south panel in east panel"}}
  end
  
  endpoint :update_west do |params|
    {:west_panel => {:set_title => "Here's an update for west panel"}}
  end
      
  js_method :on_update_west_panel, <<-JS
    function(){
      this.items.filter('name', 'west_panel').first().body.update('West Panel Body Updated');
    }
  JS
      
  js_method :on_update_center_panel, <<-JS
    function(){
      this.items.filter('name', 'center_panel').first().body.update('Center Panel Body Updated');
    }
  JS
      
  js_method :on_update_east_south_from_server, <<-JS
    function(){
      this.updateEastSouth();
    }
  JS
      
  js_method :on_update_west_from_server, <<-JS
    function(){
      this.updateWest();
    }
  JS
  
end
