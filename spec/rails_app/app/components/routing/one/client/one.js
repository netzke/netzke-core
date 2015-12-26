{
  netzkeRoutes: {
    'one/one': 'onOne',
    'one/two': 'onTwo',
  },

  onOne: function(){
    this.netzkeLoadComponent('one_one');
  },

  onTwo: function(){
    this.netzkeLoadComponent('one_two');
  }
}
