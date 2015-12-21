{
  handleShowProperties: function(ct){
    this.setTitle(this.i18n.propertyOne + " - " + this.i18n.propertyTwo);
  },

  handleActionThree: function(){
    var mask = new Ext.LoadMask(this.body);
    mask.show();
  }
}
