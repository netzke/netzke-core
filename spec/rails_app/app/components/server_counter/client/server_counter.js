{
  handleCountOneTime: function(){
    this.server.count({how_many: 1});
  },

  initComponent: function () {
    this.callParent();
    Ext.Ajax.on('beforerequest',function (conn, options ) {
      Netzke.connectionCount = Netzke.connectionCount || 0;
      Netzke.connectionCount++;
      Netzke.lastOptions=options;
    });
  },

  handleCountSevenTimes: function(){
    for(var i=0; i<7; i++) {
      this.server.count({how_many: 1});
    }
  },

  handleCountEightTimesSpecial: function(){
    for(var i=0;i<8;i++) {
      this.server.count({how_many: 1, special: true});
    }
  },

  handleFailInTheMiddle: function() {
    this.server.successingEndpoint();
    this.server.failingEndpoint();
    this.server.successingEndpoint();
  },

  handleDoOrdered: function () {
    this.server.firstEp();
    this.server.secondEp();
  },

  updateContent: function(html){
    this.update(html);
  },

  appendToTitle: function(html){
    this.title += " " + html;
    this.setTitle(this.title)
  },

  handleFailTwoOutOfFive: function(){
    this.title = "0";
    for(var i=1; i<=5; i++) {
      this.server.failTwoOutOfFive(i);
    }
  }
}
