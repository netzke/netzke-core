{
  init: function(){
    this.callParent(arguments);
    this.cmp.tools = this.cmp.tools || [];
    this.cmp.tools.push({type: 'help', handler: function(){
      var w = this.nzLoadComponent('simple_window');
    }, scope: this});
  }
}
