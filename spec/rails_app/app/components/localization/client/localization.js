{
  netzkeOnShowProperties: function(ct){
    this.setTitle(this.i18n.propertyOne + " - " + this.i18n.propertyTwo);
  },

  netzkeOnActionThree: function(){
    var mask = new Ext.LoadMask(this.body);
    mask.show();
  }
}
