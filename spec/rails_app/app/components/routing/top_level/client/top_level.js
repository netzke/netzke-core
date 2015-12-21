{
  layout: 'fit',

  netzkeRoutes: {
    'one': 'handleOne',
    'two': 'handleTwo',

    'one/one': 'handleOne',
    'one/two': 'handleOne'
  },

  handleOne: function(){
    if (this.netzkeGetComponent('one')) return;
    this.netzkeLoadComponent('one');
  },

  handleTwo: function(){
    if (this.netzkeGetComponent('two')) return;
    this.netzkeLoadComponent('two');
  },

  handleLoadOne: function(){
    this.netzkeNavigateTo('one');
  },

  handleLoadTwo: function(){
    this.netzkeNavigateTo('two');
  },

  handleLoadOneOne: function(){
    this.netzkeNavigateTo('one/one');
  },

  handleLoadOneTwo: function(){
    this.netzkeNavigateTo('one/two');
  }
}
