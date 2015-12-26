{
  title: "Component Loader",

  layout: "fit",

  netzkeOnLoadComponent: function() {
    this.netzkeLoadComponent('simple_component');
  },

  netzkeOnLoadWithFeedback: function() {
    this.netzkeLoadComponent('simple_component', { callback: function() { this.setTitle("Callback invoked!"); } });
  },

  netzkeOnLoadWindowWithSimpleComponent: function(params) {
    this.netzkeLoadComponent('window_with_simple_component');
  },

  netzkeOnLoadWithParams: function(params) {
    this.netzkeLoadComponent("simple_component", { serverConfig: { title: "Simple Component with modified title" } });
  },

  netzkeOnNonExistingComponent: function() {
    this.netzkeLoadComponent('non_existing_component');
  },

  netzkeOnLoadInWindow: function() {
    var w = new Ext.window.Window({
      width: 500, height: 400, modal: false, layout:'fit', title: 'A window'
    });
    // yes, loading should be possible *before* the component is renedered
    this.netzkeLoadComponent('component_loaded_in_window', { container: w });
    w.show();
  },

  netzkeOnInaccessible: function() {
    this.netzkeLoadComponent('inaccessible');
  },

  netzkeOnConfigOnly: function() {
    this.netzkeLoadComponent('simple_component', { configOnly: true, callback: function(config) {
      this.removeAll();
      config.title = config.title + " (overridden)";
      var instance = Ext.ComponentManager.create(config);
      this.add(instance);
    } });
  },

  netzkeOnLoadSelfReloading: function() {
    this.netzkeLoadComponent('self_reloading');
  },

  netzkeOnLoadCssInclusion: function() {
    this.netzkeLoadComponent('css_inclusion');
  },

  netzkeOnLoadDynamicChild: function(){
    this.netzkeLoadComponent('dynamic_child', {serverConfig: {klass: "Endpoints"}});
  },
}
