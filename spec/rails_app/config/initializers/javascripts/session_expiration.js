Ext.define(null, {
  override: "Netzke.Core.Mixin",
  onNetzkeSessionExpired: function() {
    this.setTitle('Session expired');
  }
})
