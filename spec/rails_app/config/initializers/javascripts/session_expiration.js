Ext.define(null, {
  override: "Netzke.Core.Component",
  onNetzkeSessionExpired: function() {
    this.setTitle('Session expired');
  }
})
