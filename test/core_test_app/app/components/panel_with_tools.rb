class PanelWithTools < Netzke::Base
  def configure(c)
    super
    c.tools = [:refresh, :gear]
  end

  js_configure do |c|
    c.on_refresh = <<-JS
      function(){
        this.setTitle("Refresh" + " clicked");
      }
    JS

    c.on_gear = <<-JS
      function(){
        this.setTitle("Gear" + " clicked")
      }
    JS
  end
end
