class PluginWithEndpoints < Netzke::Plugin
  js_configure do |c|
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
        this.serverOnGear();
      }
    JS

    c.process_gear_callback = <<-JS
      function(newTitle){
        this.cmp.setTitle(newTitle);
      }
    JS
  end

  endpoint :server_on_gear do |params, this|
    this.process_gear_callback("Response from server side of PluginWithEndpoints")
  end
end
