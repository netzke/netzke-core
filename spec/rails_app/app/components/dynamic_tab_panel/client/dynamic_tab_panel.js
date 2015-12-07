{
  activeTab: 0,
  onAddTab: function() {
    this.nzLoadComponent({name: 'tab_two', callback: function(cmp) {
      this.add(cmp);
      this.setActiveTab(cmp);
    }});
  }
}
