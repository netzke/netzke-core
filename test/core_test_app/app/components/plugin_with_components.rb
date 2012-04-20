class PluginWithComponents < Netzke::Plugin
  js_method :init, <<-JS
    function(cmp){
      this.cmp = cmp;
      this.cmp.tools = this.cmp.tools || [];
      this.cmp.tools.push({type: 'help', handler: function(){
        // we can instantiate this because it was eagerly loaded
        var w = this.instantiateChildNetzkeComponent('simple_window');
        w.show();
      }, scope: this});
    }
  JS

  component :simple_window do |c|
    c.width = 300
    c.height = 200
    c.title = "Window created by PluginWithComponents"
    c.lazy_loading = false # we want this component to be available immediately
  end
end
