{
  layout: 'fit',

  nzRoutes: {
    'one': 'handleOne',
    'two': 'handleTwo',

    'one/one': 'handleOne',
    'one/two': 'handleOne'
  },

  handleOne: function(){
    if (this.nzGetComponent('one')) return;
    this.nzLoadComponent('one');
  },

  handleTwo: function(){
    if (this.nzGetComponent('two')) return;
    this.nzLoadComponent('two');
  },

  onLoadOne: function(){
    this.nzNavigateTo('one');
  },

  onLoadTwo: function(){
    this.nzNavigateTo('two');
  },

  onLoadOneOne: function(){
    this.nzNavigateTo('one/one');
  },

  onLoadOneTwo: function(){
    this.nzNavigateTo('one/two');
  }
}
