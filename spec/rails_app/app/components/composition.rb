class Composition < Netzke::Base
  client_class do |c|
    c.height = 400
    c.layout = :border

    c.on_update_west_panel = <<-JS
      function(){
        this.getComponent('west_panel').body.update('West Panel Body Updated');
      }
    JS

    c.on_update_center_panel = <<-JS
      function(){
        this.getComponent('center_panel').body.update('Center Panel Body Updated');
      }
    JS

    c.on_update_east_south_from_server = <<-JS
      function(){
        this.server.updateEastSouth();
      }
    JS

    c.on_update_west_from_server = <<-JS
      function(){
        this.server.updateWest();
      }
    JS

    c.on_show_hidden_window = <<-JS
      function(){
        this.nzInstantiateComponent('hidden_window').show();
      }
    JS
  end

  action :update_center_panel, :update_west_panel, :update_west_from_server, :update_east_south_from_server

  action :show_hidden_window do |c|
    c.text = "Show pre-loaded window"
  end

  def configure(c)
    super
    c.bbar = [ :update_west_panel, :update_center_panel, :update_west_from_server, :update_east_south_from_server,
               :show_hidden_window ]
    c.title = c.client_config[:title] || "Composition"
    c.items = [
      :north_panel,
      :center_panel,
      { region: :west, width: 300, split: true, component: :west_panel },
      { layout: :border, region: :east, width: 500, split: true, items: [
        { region: :center, component: :east_center_panel },
        { region: :south, height: 200, split: true, component: :east_south_panel }
      ] }
    ]
  end

  component :center_panel do |c|
    c.klass = Endpoints
    c.region = :center
  end

  component :west_panel do |c|
    c.klass = EndpointsExtended
  end

  component :north_panel do |c|
    c.klass = SimpleComponent
    c.title = "Should not be seen"
    c.region = :north
    c.height = 80
    c.excluded = true
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

  # Eagerly loaded Netzke component that only requires instantiating at client
  component :hidden_window, eager_loading: true do |c|
    c.klass = SimpleWindow
    c.title = "Pre-loaded window"
    c.width = 300
    c.height = 200
    c.modal = true
  end

  endpoint :update_east_south do
    client.east_south_panel.set_title("Here's an update for south panel in east panel")
  end

  endpoint :update_west do
    client.west_panel.set_title("Here's an update for west panel")
  end
end
