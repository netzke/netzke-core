{
  activeTab: 0,
  onAddTab: function() {
    this.loadNetzkeComponent({name: 'tab_two', callback: function(cmp) {
      this.add(cmp);
      this.setActiveTab(cmp);
    }});
  }
}