{
  onSetState: function(){
    this.server.setState();
  },

  onResetState: function(){
    this.server.resetState();
  },

  onSetSessionVariable: function(){
    this.server.setSessionVariable();
  },

  onRetrieveSessionVariable: function(){
    this.server.retrieveSessionVariable(null, function(result){
      this.setTitle("Session variable: " + result);
    });
  }
}
