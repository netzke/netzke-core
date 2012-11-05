{
  title: "Component Loader",
  layout: "fit",

  onLoadWithFeedback: function(){
    this.loadNetzkeComponent({name: 'simple_component', callback: function(){
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
    this.loadNetzkeComponent({name: "window_with_simple_component", callback: function(w){
      w.show();
    }});
  },

  onLoadComposite: function(params){
    this.loadNetzkeComponent({name: "some_composite", container: this});
  },

  onLoadWithParams: function(params){
    this.loadNetzkeComponent({name: "simple_component", params: {html: "Simple Component" + " with changed HTML"}, container: this});
  },

  onLoadComponent: function(){
    this.loadNetzkeComponent({name: 'simple_component', container: this});
  },

  onNonExistingComponent: function(){
    this.loadNetzkeComponent({name: 'non_existing_component', container: this});
  },

  onLoadInWindow: function(){
    var w = new Ext.window.Window({
      width: 500, height: 400, modal: false, layout:'fit', title: 'A window'
    });
    w.show();
    this.loadNetzkeComponent({name: 'component_loaded_in_window', container: w});
  }
}
