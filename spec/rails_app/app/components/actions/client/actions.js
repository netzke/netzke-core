{
  onSimpleAction: function(){
    this.setTitle("Simple action triggered");
  },

  onAnotherAction: function(){
    this.update("Another action was triggered");
  },

  customActionHandler: function(){
    this.update("Custom action handler was called");
  },

  handleActionLessClick: function(){
    this.setTitle("Actionless button was clicked");
  }
}
