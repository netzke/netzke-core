{
  title: "Component Loader",
  layout: "fit",

  onLoadWithFeedback: function(){
    this.netzkeLoadComponent({name: 'simple_component', callback: function(){
      this.setTitle("Callback" + " invoked!");
    }, scope: this});
  },

  onLoadWithGenericCallback: function(){
    this.doNothing({}, function () {
      this.setTitle("Generic callback invoked!");
    });
  },

  onLoadWithGenericCallbackAndScope: function(){
    var that=this;
    var fancyScope={
      setFancyTitle: function () {
        that.setTitle("Fancy title set!");
      }
    };
    this.doNothing({}, function () {
      this.setFancyTitle();
    }, fancyScope);
  },

  onLoadWithGenericCallbackAndScope: function(){
    var that=this;
    var fancyScope={
      setFancyTitle: function () {
        that.setTitle("Fancy title set!");
      }
    };
    this.doNothing({}, function () {
      this.setFancyTitle();
    }, fancyScope);
  },

  onLoadWindowWithSimpleComponent: function(params){
    this.netzkeLoadComponent({name: "window_with_simple_component", callback: function(w){
      w.show();
    }});
  },

  onLoadComposite: function(params){
    this.netzkeLoadComponent({name: "some_composite", container: this});
  },

  onLoadWithParams: function(params){
    this.netzkeLoadComponent({name: "simple_component", params: {html: "Simple Component" + " with changed HTML"}, container: this});
  },

  onLoadComponent: function(){
    this.netzkeLoadComponent({name: 'simple_component', container: this});
  },

  onNonExistingComponent: function(){
    this.netzkeLoadComponent({name: 'non_existing_component', container: this});
  },

  onLoadInWindow: function(){
    var w = new Ext.window.Window({
      width: 500, height: 400, modal: false, layout:'fit', title: 'A window'
    });
    w.show();
    this.netzkeLoadComponent({name: 'component_loaded_in_window', container: w});
  },

  onInaccessible: function() {
    this.netzkeLoadComponent({name: 'inaccessible', container: this});
  }
}
