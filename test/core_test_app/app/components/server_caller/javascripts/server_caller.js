{
  onBugServer: function(){
    this.whatsUp();
    this.update('You should see the response from the server in the title bar the very next moment');
  },

  onNoResponse: function(){
    this.noResponse({}, function(){
      this.update('Successfully called endpoint with no response (this is a callback)');
    }, this);
  },

  onMultipleArguments: function(){
    this.multipleArguments();
  },

  takeTwoArguments: function(first, second){
    this.update("Called a function with two arguments: " + first + ", " + second);
  },

  onArrayAsArgument: function() {
    this.arrayAsArgument();
  },

  takeArrayAsArgument: function(arry) {
    var arryAsString = "['"+ arry.join("', '") + "']";
    this.update("Called a function with array as arguments: " + arryAsString);
  },

  onCallWithGenericCallbackAndScope: function(){
    var that=this;
    var fancyScope={
      setFancyTitle: function () {
        that.setTitle("Fancy title" + " set!");
      }
    };
    this.doNothing({}, function () {
      this.setFancyTitle();
    }, fancyScope);
  },

}
