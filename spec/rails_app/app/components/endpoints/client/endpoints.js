{
  initComponent: function(){
    this.callParent();

    Netzke.GlobalEvents.on('endpointexception', function(exception){
      this.setTitle(exception.type + ": " + exception.msg);
    }, this);
  },

  onWithResponse: function(){
    this.server.whatsUp('world');
  },

  onNoResponse: function(){
    this.server.doNothing(function(){
      this.setTitle('Successfully called endpoint with no response (this is a callback)');
    });
  },

  onMultipleArgumentResponse: function(){
    this.server.multipleArgumentResponse();
  },

  takeTwoArguments: function(first, second){
    this.setTitle("Called a function with two arguments: " + first + ", " + second);
  },

  onArrayAsArgument: function() {
    this.server.arrayAsArgument();
  },

  takeArrayAsArgument: function(arry) {
    var arryAsString = "['"+ arry.join("', '") + "']";
    this.setTitle("Called a function with array as arguments: " + arryAsString);
  },

  onCallback: function(){
    this.server.doNothing(function() {
      this.setTitle('Callback invoked');
    });
  },

  onCallbackAndScope: function() {
    var that = this;
    var fancyScope = {
      setFancyTitle: function() {
        that.setTitle("Fancy title set!");
      }
    };
    this.server.doNothing(function() {
      this.setFancyTitle();
    }, fancyScope);
  },

  onNonExisting: function(){
    this.server.nonExisting( function(error, success){
      this.setTitle("Error: " + error.type + ", message: " + error.msg);
      return false; // prevent default endpointexception exception handler
    });
  },

  onReturnValue: function() {
    this.server.getAnswer(function(answer, success) {
      this.setTitle("Returned value: " + answer + ", success: " + success);
    });
  },

  onMultipleArguments: function(){
    this.server.multipleArguments('one', 'two', 'three', function(response){
      this.setTitle("Returned value: " + response);
    });
  },

  onHashArgument: function(){
    this.server.hashArgument({one: 'one', two: 'two'}, function(response){
      this.setTitle("Returned value: " + response);
    });
  },

  onBatchedCall: function(){
    this.server.setFoo();
    this.server.appendBar();
  },

  appendTitle: function(str){
    this.setTitle(this.getTitle() + " " + str);
  },

  onRaiseException: function(){
    this.server.raise( function(res, success){
      console.log("res ", res);
      this.setTitle("Response status: " + res.xhr.status + ", success: " + success);
      return false;
    });
  },

  onReturnError: function(){
    this.server.returnError();
  }
}
