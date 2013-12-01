class PluginWithActions < Netzke::Plugin
  action :update_title

  js_configure do |c|
    c.init = <<-JS
      function(){
        this.callParent(arguments);

        // add a button to parent's toolbar
        this.cmp.addDocked({
          dock: 'bottom',
          xtype: 'toolbar',
          items: [this.actions.updateTitle]
        });
      }
    JS

    c.on_update_title = <<-JS
      function(){
        this.cmp.setTitle('Title updated by PluginWithActions');
      }
    JS
  end
end
