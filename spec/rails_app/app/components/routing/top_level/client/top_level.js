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

  onLoadOne: function(){
    this.netzkeNavigateTo('one');
  },

  onLoadTwo: function(){
    this.netzkeNavigateTo('two');
  },

  onLoadOneOne: function(){
    this.netzkeNavigateTo('one/one');
  },

  onLoadOneTwo: function(){
    this.netzkeNavigateTo('one/two');
  }
}
