{
  title: "Component Loader",
  layout: "fit",

  onLoadComponent: function(){
    this.netzkeLoadComponent('simple_component');
  },

  onLoadWithFeedback: function(){
    this.netzkeLoadComponent('simple_component', {callback: function() { this.setTitle("Callback" + " invoked!"); }, scope: this});
  },

  onLoadWindowWithSimpleComponent: function(params){
    this.netzkeLoadComponent('window_with_simple_component', {callback: function(w){ w.show(); }});
  },

  onLoadComposite: function(params){
    this.netzkeLoadComponent('some_composite');
  },

  onLoadWithParams: function(params){
    this.netzkeLoadComponent("simple_component", {params: {html: "Simple Component" + " with changed HTML"}, container: this});
  },

  onNonExistingComponent: function(){
    this.netzkeLoadComponent('non_existing_component');
  },

  onLoadInWindow: function(){
    var w = new Ext.window.Window({
      width: 500, height: 400, modal: false, layout:'fit', title: 'A window'
    });
    w.show();
    this.netzkeLoadComponent('component_loaded_in_window', {container: w});
  },

  onInaccessible: function() {
    this.netzkeLoadComponent('inaccessible');
  },

  onConfigOnly: function() {
    this.netzkeLoadComponent('simple_component', {configOnly: true, callback: function(config) {
      this.removeAll();
      config.title = config.title + " (overridden)";
      var instance = Ext.ComponentManager.create(config);
      this.add(instance);
    }, scope: this});
  }
}
