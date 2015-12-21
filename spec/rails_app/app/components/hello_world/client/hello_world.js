{
  // handler for the ping_server action
  handlePingServer: function(){
    this.server.greetTheWorld();
  },

  // called by the server as the result of executing the endpoint
  showGreeting: function(greeting){
    this.setTitle("Server says: " + greeting);
  }
}
