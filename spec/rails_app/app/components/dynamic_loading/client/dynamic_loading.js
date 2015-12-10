{
  title: "Component Loader",

  layout: "fit",

  onLoadComponent: function() {
    this.nzLoadComponent('simple_component');
  },

  onLoadWithFeedback: function() {
    this.nzLoadComponent('simple_component', { callback: function() { this.setTitle("Callback invoked!"); } });
  },

  onLoadWindowWithSimpleComponent: function(params) {
    this.nzLoadComponent('window_with_simple_component');
  },

  onLoadWithParams: function(params) {
    this.nzLoadComponent("simple_component", { serverConfig: { title: "Simple Component with modified title" } });
  },

  onNonExistingComponent: function() {
    this.nzLoadComponent('non_existing_component');
  },

  onLoadInWindow: function() {
    var w = new Ext.window.Window({
      width: 500, height: 400, modal: false, layout:'fit', title: 'A window'
    });
    // yes, loading should be possible *before* the component is renedered
    this.nzLoadComponent('component_loaded_in_window', { container: w });
    w.show();
  },

  onInaccessible: function() {
    this.nzLoadComponent('inaccessible');
  },

  onConfigOnly: function() {
    this.nzLoadComponent('simple_component', { configOnly: true, callback: function(config) {
      this.removeAll();
      config.title = config.title + " (overridden)";
      var instance = Ext.ComponentManager.create(config);
      this.add(instance);
    } });
  },

  onLoadSelfReloading: function() {
    this.nzLoadComponent('self_reloading');
  },

  onLoadCssInclusion: function() {
    this.nzLoadComponent('css_inclusion');
  },

  onLoadDynamicChild: function(){
    this.nzLoadComponent('dynamic_child', {serverConfig: {klass: "Endpoints"}});
  },
}
