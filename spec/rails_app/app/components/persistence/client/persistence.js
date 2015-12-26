{
  netzkeOnSetState: function(){
    this.server.setState();
  },

  netzkeOnResetState: function(){
    this.server.resetState();
  },

  netzkeOnSetSessionVariable: function(){
    this.server.setSessionVariable();
  },

  netzkeOnRetrieveSessionVariable: function(){
    this.server.retrieveSessionVariable(null, function(result){
      this.setTitle("Session variable: " + result);
    });
  }
}
