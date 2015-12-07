{
  init: function(){
    this.callParent(arguments);

    // inject a tool into parent
    this.cmp.tools = this.cmp.tools || [];
    this.cmp.tools = [{type: 'gear', handler: this.onGear, scope: this}];
  },

  onGear: function(){
    this.server.onGear();
  },

  processGearCallback: function(newTitle){
    this.cmp.setTitle(newTitle);
  }
}
