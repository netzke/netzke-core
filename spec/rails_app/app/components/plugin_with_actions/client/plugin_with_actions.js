{
  init: function(){
    this.callParent(arguments);

    // add a button to parent's toolbar
    this.cmp.addDocked({
      dock: 'bottom',
      xtype: 'toolbar',
      items: [this.actions.updateTitle]
    });
  },

  onUpdateTitle: function(){
    this.cmp.setTitle('Title updated by PluginWithActions');
  }
}
