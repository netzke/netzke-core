{
  activeTab: 0,
  onAddTab: function() {
    this.netzkeLoadComponent({name: 'tab_two', callback: function(cmp) {
      this.add(cmp);
      this.setActiveTab(cmp);
    }});
  }
}
