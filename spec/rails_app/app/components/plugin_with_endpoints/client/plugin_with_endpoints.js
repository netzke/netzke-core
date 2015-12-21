{
  init: function(cmp){
    this.cmp = cmp;
    // inject a tool into parent
    cmp.tools = cmp.tools || [];
    cmp.tools = [{type: 'gear', handler: this.handleGear, scope: this}];
  },

  handleGear: function(){
    this.server.onGear();
  },

  processGearCallback: function(newTitle){
    this.cmp.setTitle(newTitle);
  }
}
