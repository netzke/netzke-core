Ext.define('Netzke.NetzkeRemotingProvider', {

  extend: 'Ext.direct.RemotingProvider',
  url: Netzke.ControllerUrl + "direct/", // url to connect to the Ext.Direct server-side router.
  namespace: "Netzke.remotingMethods", // will have a key per Netzke component, each mapped to a hash with a RemotingMethod per endpoint
  maxRetries: Netzke.core.directMaxRetries,
  enableBuffer: true, // buffer/batch requests within 10ms timeframe
  timeout: 30000, // 30s timeout per request

  getPayload: function(t){
    return {
      path: t.action,
      endpoint: t.method,
      data: t.data[0],
      tid: t.id,
      type: 'rpc'
    }
  },

  // Adds remoting method to component
  addRemotingMethodToComponent: function(componentConfig, methodName) {
    var cls = this.namespace[componentConfig.id] || (this.namespace[componentConfig.id] = {});
    var method = Ext.create('Ext.direct.RemotingMethod', {name: methodName, len: 1});
    cls[methodName] = this.createHandler(componentConfig.path, method);
  }
});

Netzke.directProvider = Ext.create(Netzke.NetzkeRemotingProvider);
Ext.Direct.addProvider(Netzke.directProvider);
