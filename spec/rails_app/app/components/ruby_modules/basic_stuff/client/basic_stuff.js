{
  active_tab: 0,
  on_some_action: function(){
    this.items.last().setTitle("Action triggered");
  },
  on_another_action: function(){
    this.items.first().setTitle("Another action triggered");
  }
}
