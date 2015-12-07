{
  nzRoutes: {
    'one/one': 'handleOne',
    'one/two': 'handleTwo',
  },

  handleOne: function(){
    this.nzLoadComponent('one_one');
  },

  handleTwo: function(){
    this.nzLoadComponent('one_two');
  }
}
