{
  prebuiltControlConfig: function(config){
    return {
      xtype: 'datefield',
      listeners: {
        select: function(){
          this.nzParent.body.update('Hi');
        }
      }
    }
  }
}
