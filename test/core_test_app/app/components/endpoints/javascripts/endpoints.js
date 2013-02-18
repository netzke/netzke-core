{
  onWithResponse: function(){
    this.whatsUp();
  },

  onNoResponse: function(){
    this.noResponse({}, function(){
      this.setTitle('Successfully called endpoint with no response (this is a callback)');
    }, this);
  },

  onMultipleArguments: function(){
    this.multipleArguments();
  },

  takeTwoArguments: function(first, second){
    this.setTitle("Called a function with two arguments: " + first + ", " + second);
  },

  onArrayAsArgument: function() {
    this.arrayAsArgument();
  },

  takeArrayAsArgument: function(arry) {
    var arryAsString = "['"+ arry.join("', '") + "']";
    this.setTitle("Called a function with array as arguments: " + arryAsString);
  },

  onCallbackAndScope: function(){
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

  onReturnValue: function() {
    this.getAnswer(null, function(answer) {
      this.setTitle("Returned value: " + answer);
    }, this);
  }
}
