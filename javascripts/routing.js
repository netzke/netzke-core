Ext.define(null, {
  override: 'Netzke.Core.Component',

  netzkeAfterInitComponent: function(){
    if (this.netzkeRoutes) {
      var routes = this.netzkeGetRoutes();
      this.netzkeRouter = Ext.create('Ext.app.Controller', { routes: this.netzkeGetRoutes() });
      this.on('beforedestroy', this.netzkeCleanRoutes, this);

      this.on('render', function(){
        this.netzkeTriggerInitialRoute();
      });
    }

    this.callParent();
  },

  netzkeNavigateTo: function(route, options){
    options = options || {};
    var newRoute = route;
    if (options.append) {
      newRoute = Ext.util.History.getToken() + "/" + newRoute;
    }
    this.netzkeRouter.redirectTo(newRoute);
  },

  // private

  netzkeCleanRoutes: function(){
    this.netzkeRouter.destroy();
  },

  netzkeTriggerInitialRoute: function(){
    var initToken = Ext.util.History.getToken();
    if (initToken) this.netzkeRouter.redirectTo(initToken, true);
  },

  netzkeGetRoutes: function(){
    var out = {};
    for (var route in this.netzkeRoutes) {
      var handlerName = this.netzkeRoutes[route],
          handler = this[handlerName];
      if (!handler) throw("Netzke: route handler " + handlerName + " is not defined");
      out[route] = handler.bind(this);
    }
    return out;
  }
});
