{
  // handler for the ping_server action
  onPingServer: function(){
    this.greetTheWorld();
    var cfg = this.nzBuildParentConfigs();
  },

  // called by the server as the result of executing the endpoint
  showGreeting: function(greeting){
    this.setTitle("Server says: " + greeting);
  }
}
