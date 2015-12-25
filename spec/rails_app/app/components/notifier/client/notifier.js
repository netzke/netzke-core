{
  handleNotify: function(){
    this.netzkeNotify('Local' + ' feedback', {title: 'Local' + ' notification'});
  },

  handleServerNotify: function(){
    this.server.notify();
  },

  handleMultipleNotify: function(){
    this.netzkeNotify(['Line' + ' one', 'Line' + ' two']);
  }
}
