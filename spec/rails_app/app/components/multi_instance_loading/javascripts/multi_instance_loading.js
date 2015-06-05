{
  onLoadHelloUser: function() {
    this.counter = this.counter || 0;
    this.counter++;
    this.netzkeLoadComponent('hello_user', {
      configOnly: true,
      callback: this.persistentTabDelivered,
      scope: this,
      clone: true,
      clientConfig: {user: 'User ' + this.counter}
    });
  },

  onLoadHelloUserInPrecreatedTab: function() {
    this.counter = this.counter || 0;
    this.counter++;
    var tab = this.add(Ext.ComponentManager.create({xtype: 'panel', layout: 'fit', title: 'Tab ' + this.counter}));
    this.setActiveTab(tab);
    this.netzkeLoadComponent('hello_user', {
      container: tab,
      scope: this,
      clone: true,
      clientConfig: {user: 'User ' + this.counter}
    });
  },

  onLoadComposition: function() {
    this.counter = this.counter || 0;
    this.counter++;
    this.netzkeLoadComponent('composition', {
      configOnly: true,
      callback: this.persistentTabDelivered,
      scope: this,
      clone: true,
      clientConfig: {title: 'Composition ' + this.counter}
    });
  },

  persistentTabDelivered: function(c) {
    var tab = this.add(Ext.ComponentManager.create(c));
    this.setActiveTab(tab);
  }
}
