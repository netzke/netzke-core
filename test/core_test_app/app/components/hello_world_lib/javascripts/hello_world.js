{
  // handler for the ping_server action
  onPingServer: function(){
    // calling greet_the_world endpoint
    this.greetTheWorld();
  },

  // called by the server as the result of executing the endpoint
  showGreeting: function(greeting){
    this.update("Server says: " + greeting);
  }
}
