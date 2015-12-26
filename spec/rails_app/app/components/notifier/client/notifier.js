{
  netzkeOnNotify: function(){
    this.netzkeNotify('Local' + ' feedback', {title: 'Local' + ' notification'});
  },

  netzkeOnServerNotify: function(){
    this.server.notify();
  },

  netzkeOnMultipleNotify: function(){
    this.netzkeNotify(['Line' + ' one', 'Line' + ' two']);
  }
}
