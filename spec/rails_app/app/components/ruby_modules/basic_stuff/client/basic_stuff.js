{
  active_tab: 0,
  handleSomeAction: function(){
    this.items.last().setTitle("Action triggered");
  },
  handleAnotherAction: function(){
    this.items.first().setTitle("Another action triggered");
  }
}
