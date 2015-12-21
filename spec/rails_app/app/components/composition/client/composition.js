{
  layout: 'border',

  handleWestPanel: function(){
    this.getComponent('west_panel').body.update('West Panel Body Updated');
  },

  handleUpdateCenterPanel: function(){
    this.getComponent('center_panel').body.update('Center Panel Body Updated');
  },

  handleUpdateEastSouthFromServer: function(){
    this.server.updateEastSouth();
  },

  handleUpdateWestFromServer: function(){
    this.server.updateWest();
  },

  handleShowHiddenWindow: function(){
    this.netzkeInstantiateComponent('hidden_window').show();
  }
}
