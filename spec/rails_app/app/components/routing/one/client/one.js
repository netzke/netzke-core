{
  netzkeRoutes: {
    'one/one': 'handleOne',
    'one/two': 'handleTwo',
  },

  handleOne: function(){
    this.netzkeLoadComponent('one_one');
  },

  handleTwo: function(){
    this.netzkeLoadComponent('one_two');
  }
}
