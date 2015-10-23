{
  title: "Component Loader",

  layout: "fit",

  onLoadComponent: function() {
    this.netzkeLoadComponent('simple_component');
  },

  onLoadWithFeedback: function() {
    this.netzkeLoadComponent('simple_component', { callback: function() { this.setTitle("Callback invoked!"); } });
  },

  onLoadWindowWithSimpleComponent: function(params) {
    this.netzkeLoadComponent('window_with_simple_component');
  },

  onLoadWithParams: function(params) {
    this.netzkeLoadComponent("simple_component", { serverConfig: { title: "Simple Component with modified title" } });
  },

  onNonExistingComponent: function() {
    this.netzkeLoadComponent('non_existing_component');
  },

  onLoadInWindow: function() {
    var w = new Ext.window.Window({
      width: 500, height: 400, modal: false, layout:'fit', title: 'A window'
    });
    // yes, loading should be possible *before* the component is renedered
    this.netzkeLoadComponent('component_loaded_in_window', { container: w });
    w.show();
  },

  onInaccessible: function() {
    this.netzkeLoadComponent('inaccessible');
  },

  onConfigOnly: function() {
    this.netzkeLoadComponent('simple_component', { configOnly: true, callback: function(config) {
      this.removeAll();
      config.title = config.title + " (overridden)";
      var instance = Ext.ComponentManager.create(config);
      this.add(instance);
    } });
  },

  onLoadSelfReloading: function() {
    this.netzkeLoadComponent('self_reloading');
  },

  onLoadCssInclusion: function() {
    this.netzkeLoadComponent('css_inclusion');
  }
}
