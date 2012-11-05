class MultipaneComponentLoader < Netzke::Base
  js_property :layout, {:type => :hbox, :align => :stretch}
  js_property :prevent_header, true

  action :load_server_caller, :handler => :load_handler
  action :load_component_loader, :handler => :load_handler

  def configure(c)
    super
    c.items = [{
      :title => "Container One",
      :xtype => :panel,
      :height => 200,
      :flex => 1,
      :border => true,
      :bbar => [:load_server_caller, :load_component_loader],
      :layout => :fit
    },{
      :title => "Container Two",
      :xtype => :panel,
      :height => 200,
      :flex => 1,
      :layout => :fit
    }]
  end

  component :server_caller

  js_method :load_handler, <<-JS
    function(button){
      var container = button.ownerCt.ownerCt;
      this.loadNetzkeComponent({name: 'server_caller', container: container});
    }
  JS

  def deliver_component_endpoint(params)
    sleep 1 # for visual evaluation
    super
  end

end
