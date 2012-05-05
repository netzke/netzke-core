class SomePlugin < Netzke::Plugin
  action :action_one

  js_method :init, <<-JS
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

  js_method :on_action_one, <<-JS
    function(){
      this.cmp.setTitle('Action one ' + 'triggered');
    }
  JS

  js_method :on_gear, <<-JS
    function(){
      this.processGear();
    }
  JS

  js_method :process_gear_callback, <<-JS
    function(newTitle){
      this.cmp.setTitle(newTitle);
    }
  JS

  endpoint :process_gear do |params, this|
    this.process_gear_callback("Server response")
  end

end
