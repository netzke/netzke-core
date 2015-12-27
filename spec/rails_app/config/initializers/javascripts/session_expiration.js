Ext.define(null, {
  override: "Netzke.Base",
  netzkeOnSessionExpired: function() {
    this.setTitle('Session expired');
  }
})
