{
  layout: 'fit',

  netzkeRoutes: {
    'one': 'onOne',
    'two': 'onTwo',

    'one/one': 'onOne',
    'one/two': 'onOne'
  },

  onOne: function(){
    if (this.netzkeGetComponent('one')) return;
    this.netzkeLoadComponent('one');
  },

  onTwo: function(){
    if (this.netzkeGetComponent('two')) return;
    this.netzkeLoadComponent('two');
  },

  netzkeOnLoadOne: function(){
    this.netzkeNavigateTo('one');
  },

  netzkeOnLoadTwo: function(){
    this.netzkeNavigateTo('two');
  },

  netzkeOnLoadOneOne: function(){
    this.netzkeNavigateTo('one/one');
  },

  netzkeOnLoadOneTwo: function(){
    this.netzkeNavigateTo('one/two');
  }
}
