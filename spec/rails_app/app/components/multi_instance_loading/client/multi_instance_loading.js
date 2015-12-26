{
  counter: 0,

  netzkeOnLoadHelloUser: function() {
    this.counter++;
    this.netzkeLoadComponent('hello_user', {
      itemId: "hello_user_" + this.counter,
      append: true,
      serverConfig: {user_name: 'User ' + this.counter}
    });
  },

  netzkeOnLoadHelloUserInPrecreatedTab: function() {
    this.counter++;
    var tab = this.add(Ext.ComponentManager.create({xtype: 'panel', layout: 'fit', title: 'Tab ' + this.counter}));
    this.setActiveTab(tab);
    this.netzkeLoadComponent('hello_user', {
      itemId: "hello_user_" + this.counter,
      container: tab,
      serverConfig: {user_name: 'User ' + this.counter}
    });
  },

  netzkeOnLoadComposition: function() {
    this.counter++;
    this.netzkeLoadComponent('composition', {
      itemId: "hello_user_" + this.counter,
      serverConfig: {title: 'Composition ' + this.counter}
    });
  },

  netzkeOnLoadConfigOnly: function(){
    this.counter++;
    this.netzkeLoadComponent('composition', {
      configOnly: true,
      itemId: "custom_item_id",
      callback: function(config){
        this.setTitle("Loaded itemId: " + config.itemId);
      }
    });
  }
}
