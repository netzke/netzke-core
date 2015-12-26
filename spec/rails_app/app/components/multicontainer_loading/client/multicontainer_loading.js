{
  netzkeOnReplaceTabInLeft: function(){
    var leftTabOne = this.getComponent('left').getComponent('one');
    this.netzkeLoadComponent('hello_user', {
      replace: leftTabOne,
      itemId: "hello_user_one",
      serverConfig: {user_name: 'Foo'}
    });
  },

  netzkeOnLoadInRight: function(){
    var right = this.getComponent('right');
    this.netzkeLoadComponent('hello_user', {
      container: right,
      itemId: "hello_user_two",
      serverConfig: {user_name: 'Bar'}
    });
  },
}
