Ext.define('Netzke.classes.NetzkeRemotingProvider', {
  extend: 'Ext.direct.RemotingProvider',
  type: 'netzkeremoting',
  alias:  'direct.netzkeremotingprovider',

  maxRetries: Netzke.core.directMaxRetries,
  url: Netzke.ControllerUrl + 'direct/',

  callBuffer: [], // call buffer shared between instances

  // override
  constructor: function(){
    this.callParent(arguments);
    this.callBuffer = this.getSharedCallBuffer();
  },

  // override
  getPayload: function(t){
    return {
      path: t.action,
      endpoint: t.method,
      data: {configs: this.netzkeOwner.netzkeBuildParentConfigs(), args: t.data[0]},
      tid: t.id,
      type: 'rpc'
    }
  },

  getSharedCallBuffer: function(){
    return Object.getPrototypeOf(this).callBuffer;
  },

  // override
  combineAndSend: function() {
    this.callParent();
    if (this.callBuffer != this.getSharedCallBuffer() && this.callBuffer.length == 0) {
      // prevent parent from referencing to the *new* empty callBuffer
      this.callBuffer = this.getSharedCallBuffer();
      this.callBuffer.length = 0;
    }
  }
});
