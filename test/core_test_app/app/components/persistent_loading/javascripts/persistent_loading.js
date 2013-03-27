{
  onPersistentTab: function() {
    this.netzkeLoadComponent('tab', {configOnly: true, callback: this.persistentTabDelivered, scope: this, clone: true});
  },

  onTemporaryTab: function() {
  },

  persistentTabDelivered: function(c) {
    var tab = this.add(Ext.ComponentManager.create(c));
    this.setActiveTab(tab);
  }
}
