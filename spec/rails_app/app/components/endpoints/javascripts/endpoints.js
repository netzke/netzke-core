{
  initComponent: function(){
    this.callParent();

    Netzke.GlobalEvents.on('endpointexception', function(exception){
      this.setTitle(exception.type + ": " + exception.msg);
    }, this);
  },

  onWithResponse: function(){
    this.whatsUp('world');
  },

  onNoResponse: function(){
    this.doNothing(function(){
      this.setTitle('Successfully called endpoint with no response (this is a callback)');
    });
  },

  onMultipleArgumentResponse: function(){
    this.multipleArgumentResponse();
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

  onCallbackAndScope: function() {
    var that = this;
    var fancyScope = {
      setFancyTitle: function() {
        that.setTitle("Fancy title set!");
      }
    };
    this.doNothing(function() {
      this.setFancyTitle();
    }, fancyScope);
  },

  onNonExisting: function(){
    this.serverNonExisting( function(error, success){
      this.setTitle("Error: " + error.type + ", message: " + error.msg);
      return false; // prevent default endpointexception exception handler
    });
  },

  onReturnValue: function() {
    this.getAnswer(function(answer, success) {
      this.setTitle("Returned value: " + answer + ", success: " + success);
    });
  },

  onMultipleArguments: function(){
    this.serverMultipleArguments('one', 'two', 'three', function(response){
      this.setTitle("Returned value: " + response);
    });
  },

  onHashArgument: function(){
    this.serverHashArgument({one: 'one', two: 'two'}, function(response){
      this.setTitle("Returned value: " + response);
    });
  },

  onBatchedCall: function(){
    this.serverSetFoo();
    this.serverAppendBar();
  },

  appendTitle: function(str){
    this.setTitle(this.getTitle() + " " + str);
  },

  onRaiseException: function(){
    this.serverRaise( function(res, success){
      console.log("res ", res);
      this.setTitle("Response status: " + res.xhr.status + ", success: " + success);
      return false;
    });
  },

  onReturnError: function(){
    this.serverReturnError();
  }
}
