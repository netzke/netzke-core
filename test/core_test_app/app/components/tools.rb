class Tools < Netzke::Base
  def configure(c)
    super
    c.tools = [:refresh, :gear]
  end

  js_configure do |c|
    c.on_refresh = <<-JS
      function(){
        this.setTitle("Refresh tool clicked");
      }
    JS

    c.on_gear = <<-JS
      function(){
        this.setTitle("Gear tool clicked")
      }
    JS
  end
end
