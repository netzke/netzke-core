Ext.define(null, {
  override: "Netzke.Core.Component",
  netzkeOnSessionExpired: function() {
    this.setTitle('Session expired');
  }
})
