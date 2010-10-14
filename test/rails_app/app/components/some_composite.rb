class SomeComposite < Netzke::Base
  js_properties :title => "Static Composite", :layout => 'border'
  
  action :update_center_panel
  action :update_west_panel
  action :update_west_from_server
  action :update_east_south_from_server
  
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
      :bbar => [:update_west_panel.action, :update_center_panel.action, :update_west_from_server.action, :update_east_south_from_server.action]
    }.deep_merge super
  end
  
  component :center_panel, :class_name => "ServerCaller"
  
  component :east_panel, :class_name => "BorderLayoutPanel", :items => [{
      :name => :center_panel,
      :class_name => "SimpleComponent",
      :title => "A panel",
      :region => :center
    },{
      :class_name => "SimpleComponent",
      :region => :south,
      :title => "Another panel",
      :height => 200,
      :split => true
  }]
  
  endpoint :update_east_south do |params|
    {:east_panel => {:simple_component1 => {:set_title => "Here's an update for south panel in east panel"}}}
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
