{
  layout: 'border',

  initComponent: function(){
    this.callParent();

    Ext.Ajax.on('beforerequest',function (conn, options ) {
      Netzke.connectionCount = Netzke.connectionCount || 0;
      Netzke.connectionCount++;
    });

    this.netzkeGetComponent('selector').on('userupdate', function(user){
      this.server.setUser(user);
      this.netzkeGetComponent('details').server.update();
      this.netzkeGetComponent('statistics').server.update();
    }, this);
  }
}
