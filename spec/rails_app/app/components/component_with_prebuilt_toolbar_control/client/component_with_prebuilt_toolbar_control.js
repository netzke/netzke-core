{
  prebuiltControlConfig: function(config){
    return {
      xtype: 'datefield',
      listeners: {
        select: function(){
          this.netzkeParent.body.update('Hi');
        }
      }
    }
  }
}
