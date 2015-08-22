{
  counter: 0,

  onLoadHelloUser: function() {
    this.counter++;
    this.netzkeLoadComponent('hello_user', {
      itemId: "hello_user_" + this.counter,
      append: true,
      serverConfig: {user_name: 'User ' + this.counter}
    });
  },

  onLoadHelloUserInPrecreatedTab: function() {
    this.counter++;
    var tab = this.add(Ext.ComponentManager.create({xtype: 'panel', layout: 'fit', title: 'Tab ' + this.counter}));
    this.setActiveTab(tab);
    this.netzkeLoadComponent('hello_user', {
      itemId: "hello_user_" + this.counter,
      container: tab,
      serverConfig: {user_name: 'User ' + this.counter}
    });
  },

  onLoadComposition: function() {
    this.counter++;
    this.netzkeLoadComponent('composition', {
      itemId: "hello_user_" + this.counter,
      serverConfig: {title: 'Composition ' + this.counter}
    });
  }
}
