{
  title: "Component Loader",

  layout: "fit",

  handleLoadComponent: function() {
    this.netzkeLoadComponent('simple_component');
  },

  handleLoadWithFeedback: function() {
    this.netzkeLoadComponent('simple_component', { callback: function() { this.setTitle("Callback invoked!"); } });
  },

  handleLoadWindowWithSimpleComponent: function(params) {
    this.netzkeLoadComponent('window_with_simple_component');
  },

  handleLoadWithParams: function(params) {
    this.netzkeLoadComponent("simple_component", { serverConfig: { title: "Simple Component with modified title" } });
  },

  handleNonExistingComponent: function() {
    this.netzkeLoadComponent('non_existing_component');
  },

  handleLoadInWindow: function() {
    var w = new Ext.window.Window({
      width: 500, height: 400, modal: false, layout:'fit', title: 'A window'
    });
    // yes, loading should be possible *before* the component is renedered
    this.netzkeLoadComponent('component_loaded_in_window', { container: w });
    w.show();
  },

  handleInaccessible: function() {
    this.netzkeLoadComponent('inaccessible');
  },

  handleConfigOnly: function() {
    this.netzkeLoadComponent('simple_component', { configOnly: true, callback: function(config) {
      this.removeAll();
      config.title = config.title + " (overridden)";
      var instance = Ext.ComponentManager.create(config);
      this.add(instance);
    } });
  },

  handleLoadSelfReloading: function() {
    this.netzkeLoadComponent('self_reloading');
  },

  handleLoadCssInclusion: function() {
    this.netzkeLoadComponent('css_inclusion');
  },

  handleLoadDynamicChild: function(){
    this.netzkeLoadComponent('dynamic_child', {serverConfig: {klass: "Endpoints"}});
  },
}
