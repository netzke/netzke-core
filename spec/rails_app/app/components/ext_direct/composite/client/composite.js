{
  layout: 'border',

  initComponent: function(){
    this.callParent();

    Ext.Ajax.on('beforerequest',function (conn, options ) {
      Netzke.connectionCount = Netzke.connectionCount || 0;
      Netzke.connectionCount++;
    });

    this.nzGetComponent('selector').on('userupdate', function(user){
      this.server.setUser(user);
      this.nzGetComponent('details').server.update();
      this.nzGetComponent('statistics').server.update();
    }, this);
  }
}
