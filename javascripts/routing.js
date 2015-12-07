Ext.define(null, {
  override: 'Netzke.Core.Component',

  nzAfterInitComponent: function(){
    if (this.nzRoutes) {
      var routes = this.nzGetRoutes();
      this.nzRouter = Ext.create('Ext.app.Controller', { routes: this.nzGetRoutes() });
      this.on('beforedestroy', this.nzCleanRoutes, this);

      this.on('render', function(){
        this.nzTriggerInitialRoute();
      });
    }

    this.callParent();
  },

  nzNavigateTo: function(route, options){
    options = options || {};
    var newRoute = route;
    if (options.append) {
      newRoute = Ext.util.History.getToken() + "/" + newRoute;
    }
    this.nzRouter.redirectTo(newRoute);
  },

  // private

  nzCleanRoutes: function(){
    this.nzRouter.destroy();
  },

  nzTriggerInitialRoute: function(){
    var initToken = Ext.util.History.getToken();
    if (initToken) this.nzRouter.redirectTo(initToken, true);
  },

  nzGetRoutes: function(){
    var out = {};
    for (var route in this.nzRoutes) {
      var handlerName = this.nzRoutes[route],
          handler = this[handlerName];
      if (!handler) throw("Netzke: route handler " + handlerName + " is not defined");
      out[route] = handler.bind(this);
    }
    return out;
  }
});
