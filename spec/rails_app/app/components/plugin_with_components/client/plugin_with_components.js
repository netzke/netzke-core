{
  init: function(cmp){
    cmp.tools = cmp.tools || [];
    cmp.tools.push({type: 'help', handler: function(){
      var w = this.netzkeLoadComponent('simple_window');
    }, scope: this});
  }
}
