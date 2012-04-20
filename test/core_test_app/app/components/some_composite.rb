class SomeComposite < Netzke::Base
  js_properties :height => 400,
                :layout => 'border',
                :bbar => [
                  :update_west_panel,
                  :update_center_panel,
                  :update_west_from_server,
                  :update_east_south_from_server
                ]

  action :update_center_panel
  action :update_west_panel
  action :update_west_from_server
  action :update_east_south_from_server

  def items
    [
      { region: :center, netzke_component: :center_panel },
      { region: :west, width: 300, split: true, netzke_component: :west_panel },
      { layout: :border, region: :east, width: 500, split: true, items: [
        { region: :center, netzke_component: :east_center_panel },
        { region: :south, height: 200, split: true, netzke_component: :east_south_panel }
      ] }
    ]
  end

  component :center_panel do |c|
    c.klass = ServerCaller
  end

  component :west_panel do |c|
    c.klass = ExtendedServerCaller
  end

  component :east_center_panel do |c|
    c.klass = SimpleComponent
    c.title = "A panel"
    c.border = false
  end

  component :east_south_panel do |c|
    c.klass = SimpleComponent
    c.title = "Another panel"
    c.border = false
  end

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
