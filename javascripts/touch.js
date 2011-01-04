Ext.ns("Netzke.classes.Core");
Ext.apply(Netzke.classes.Core.Mixin, {
  /* initComponent common for all Netzke components */
  initComponentWithNetzke: function(){
    this.detectActions(this);

    this.detectComponents(this.items);

    this.processEndpoints();

    // This is where the references to different callback functions will be stored
    this.callbackHash = {};

    // Call the original initComponent
    this.initComponentWithoutNetzke();
  },

  /*
  Detects action configs in the passed object, and replaces them with instances of Ext.Action created by normalizeActions().
  This detects action in arbitrary level of nesting, which means you can put any other components in your toolbar, and inside of them specify menus/items or even toolbars.
  */
  detectActions: function(o){
    if (Ext.isObject(o)) {
      if ((typeof o.handler === 'string') && Ext.isFunction(this[o.handler.camelize(true)])) {
         // This button config has a handler specified as string - replace it with reference to a real function if it exists
        o.handler = this[o.handler.camelize(true)];
        o.scope = this;
      }
      // TODO: this should be configurable!
      Ext.each(["items", "dockedItems"], function(key){
        if (o[key]) {
          var items = [].concat(o[key]); // we need to do it in order to esure that this instance has a separate bbar/tbar/etc, NOT shared via class' prototype
          delete(o[key]);
          o[key] = items;
          this.detectActions(o[key]);
        }
      }, this);
    } else if (Ext.isArray(o)) {
      var a = o;
      Ext.each(a, function(el, i){
        if (Ext.isObject(el)) {
          this.detectActions(el);
        }
      }, this);
    }
  }
});
