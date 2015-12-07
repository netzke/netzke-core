class PluginWithEndpoints < Netzke::Plugin
  client_class do |c|
    c.init = <<-JS
      function(){
        this.callParent(arguments);

        // inject a tool into parent
        this.cmp.tools = this.cmp.tools || [];
        this.cmp.tools = [{type: 'gear', handler: this.onGear, scope: this}];
      }
    JS

    c.on_gear = <<-JS
      function(){
        this.server.onGear();
      }
    JS

    c.process_gear_callback = <<-JS
      function(newTitle){
        this.cmp.setTitle(newTitle);
      }
    JS
  end

  endpoint :on_gear do
    client.process_gear_callback("Response from server side of PluginWithEndpoints")
  end
end
