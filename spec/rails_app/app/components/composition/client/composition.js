{
  layout: 'border',

  onWestPanel: function(){
    this.getComponent('west_panel').body.update('West Panel Body Updated');
  },

  onUpdateCenterPanel: function(){
    this.getComponent('center_panel').body.update('Center Panel Body Updated');
  },

  onUpdateEastSouthFromServer: function(){
    this.server.updateEastSouth();
  },

  onUpdateWestFromServer: function(){
    this.server.updateWest();
  },

  onShowHiddenWindow: function(){
    this.nzInstantiateComponent('hidden_window').show();
  }
}
