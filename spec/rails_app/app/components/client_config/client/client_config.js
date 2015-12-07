{
  onShowOption: function(action) {
    this.serverConfig.some_option = action.option;
    this.server.requestSomeOption(null, function(res){this.setTitle(res);});

    var left = this.nzGetComponent('left');
    var right = this.nzGetComponent('right');

    left.serverConfig = {user_name: action.option + " Left"};
    right.serverConfig = {user_name: action.option + " Right"};
    left.onPingServer();
    right.onPingServer();
  }
}
