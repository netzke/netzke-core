{
  layout: 'border',

  netzkeOnWestPanel: function(){
    this.getComponent('west_panel').body.update('West Panel Body Updated');
  },

  netzkeOnUpdateCenterPanel: function(){
    this.getComponent('center_panel').body.update('Center Panel Body Updated');
  },

  netzkeOnUpdateEastSouthFromServer: function(){
    this.server.updateEastSouth();
  },

  netzkeOnUpdateWestFromServer: function(){
    this.server.updateWest();
  },

  netzkeOnShowHiddenWindow: function(){
    this.netzkeInstantiateComponent('hidden_window').show();
  }
}
