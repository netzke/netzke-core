{
  netzkeOnSimpleAction: function(){
    this.setTitle("Simple action triggered");
  },

  netzkeOnAnotherAction: function(){
    this.update("Another action was triggered");
  },

  customActionHandler: function(){
    this.update("Custom action handler was called");
  },

  onActionlessClick: function(){
    this.setTitle("Actionless button was clicked");
  }
}
