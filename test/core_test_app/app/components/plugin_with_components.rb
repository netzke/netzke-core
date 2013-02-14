class PluginWithComponents < Netzke::Plugin
  js_configure do |c|
    c.init = <<-JS
      function(cmp){
        this.cmp = cmp;
        this.cmp.tools = this.cmp.tools || [];
        this.cmp.tools.push({type: 'help', handler: function(){
          // we can instantiate this because it was eagerly loaded
          var w = this.netzkeInstantiateComponent('simple_window');
          w.show();
        }, scope: this});
      }
    JS
  end

  component :simple_window do |c|
    c.width = 300
    c.height = 200
    c.title = "Window created by PluginWithComponents"
    c.eager_loading = true
  end
end
