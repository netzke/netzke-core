Ext.define(null, {
  override: "Netzke.classes.Core.Mixin",
  onNetzkeSessionExpired: function() {
    this.setTitle('Session expired');
  }
})
