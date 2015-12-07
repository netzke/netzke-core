{
  onReplaceTabInLeft: function(){
    var leftTabOne = this.getComponent('left').getComponent('one');
    this.nzLoadComponent('hello_user', {
      replace: leftTabOne,
      itemId: "hello_user_one",
      serverConfig: {user_name: 'Foo'}
    });
  },

  onLoadInRight: function(){
    var right = this.getComponent('right');
    this.nzLoadComponent('hello_user', {
      container: right,
      itemId: "hello_user_two",
      serverConfig: {user_name: 'Bar'}
    });
  },
}
