class PanelWithTools < Netzke::Base

  def configure
    super
    config.tools = [:refresh, :gear]
  end

  js_method :on_refresh, <<-JS
    function(){
      this.setTitle("Refresh" + " clicked");
    }
  JS

  js_method :on_gear, <<-JS
    function(){
      this.setTitle("Gear" + " clicked")
    }
  JS

end
