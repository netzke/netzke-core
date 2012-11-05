class SomePlugin < Netzke::Plugin
  action :action_one

  js_configure do |c|
    c.init = <<-JS
      function(){
        this.callParent(arguments);
        this.cmp.tools = [{id: 'gear', handler: this.onGear, scope: this}];

        this.cmp.addDocked({
          dock: 'bottom',
          xtype: 'toolbar',
          items: [this.actions.actionOne]
        });
      }
    JS

    c.on_action_one = <<-JS
      function(){
        this.cmp.setTitle('Action one ' + 'triggered');
      }
    JS

    c.on_gear = <<-JS
      function(){
        this.processGear();
      }
    JS

    c.process_gear_callback = <<-JS
      function(newTitle){
        this.cmp.setTitle(newTitle);
      }
    JS
  end

  endpoint :process_gear do |params, this|
    this.process_gear_callback("Server response")
  end
end
