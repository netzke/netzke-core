{
  handleSetState: function(){
    this.server.setState();
  },

  handleResetState: function(){
    this.server.resetState();
  },

  handleSetSessionVariable: function(){
    this.server.setSessionVariable();
  },

  handleRetrieveSessionVariable: function(){
    this.server.retrieveSessionVariable(null, function(result){
      this.setTitle("Session variable: " + result);
    });
  }
}
