Ext.define(null, {
  override: "Netzke.Core.Component",
  handleSessionExpired: function() {
    this.setTitle('Session expired');
  }
})
