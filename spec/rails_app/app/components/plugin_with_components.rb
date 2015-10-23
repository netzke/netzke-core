class PluginWithComponents < Netzke::Plugin
  client_class do |c|
    c.init = <<-JS
      function(){
        this.callParent(arguments);
        this.cmp.tools = this.cmp.tools || [];
        this.cmp.tools.push({type: 'help', handler: function(){
          // we can instantiate this because it was eagerly loaded
          var w = this.netzkeInstantiateComponent('simple_window');
          w.show();
        }, scope: this});
      }
    JS
  end

  component :simple_window, eager_loading: true do |c|
    c.width = 300
    c.height = 200
    c.title = "Window added by PluginWithComponents"
  end
end
