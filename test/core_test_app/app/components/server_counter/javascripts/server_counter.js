{
  onCountOneTime: function(){
    this.count({how_many: 1});
  },

  initComponent: function () {
    this.callParent();
    Ext.Ajax.on('beforerequest',function (conn, options ) {
      Netzke.connectionCount = Netzke.connectionCount || 0;
      Netzke.connectionCount++;
      Netzke.lastOptions=options;
    });
  },

  onCountSevenTimes: function(){
    for(var i=0; i<7; i++) {
      this.count({how_many: 1});
    }
  },

  onCountEightTimesSpecial: function(){
    for(var i=0;i<8;i++) {
      this.count({how_many: 1, special: true});
    }
  },

  onFailInTheMiddle: function() {
    this.successingEndpoint();
    this.failingEndpoint();
    this.successingEndpoint();
  },

  onDoOrdered: function () {
    this.firstEp();
    this.secondEp();
  },

  updateContent: function(html){
    this.update(html);
  },

  appendToTitle: function(html){
    this.titl += " " + html;
    this.setTitle(this.titl)
  },

  onFailTwoOutOfFive: function(){
    this.titl = "0";
    for(var i=1; i<=5; i++) {
      this.failTwoOutOfFive(i);
    }
  }
}
