{
  onPersistentTab: function() {
    this.counter = this.counter || 0;
    this.counter++;
    this.netzkeLoadComponent('tab', {configOnly: true, callback: this.persistentTabDelivered, scope: this, clone: true, clientConfig: {user: 'User ' + this.counter}});
  },

  onTemporaryTab: function() {
  },

  persistentTabDelivered: function(c) {
    var tab = this.add(Ext.ComponentManager.create(c));
    this.setActiveTab(tab);
  }
}
