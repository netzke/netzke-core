{
  onShowProperties: function(ct){
    this.setTitle(this.i18n.propertyOne + " - " + this.i18n.propertyTwo);
  },

  onActionThree: function(){
    var mask = new Ext.LoadMask(this.body);
    mask.show();
  }
}
