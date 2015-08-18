// FeedbackGhost is a little class that displays unified feedback from Netzke components.
Ext.define('Netzke.FeedbackGhost', {
  showFeedback: function(msg, options){
    options = options || {};
    options.delay = options.delay || Netzke.core.FeedbackDelay;
    if (Ext.isObject(msg)) {
      this.msg(msg.level.camelize(), msg.msg, options.delay);
    } else if (Ext.isArray(msg)) {
      Ext.each(msg, function(m) { this.showFeedback(m); }, this);
    } else {
      this.msg(null, msg, options.delay); // no header for now
    }
  },

  msg: function(title, format, delay){
      if(!this.msgCt){
          this.msgCt = Ext.core.DomHelper.insertFirst(document.body, {id:'msg-div'}, true);
      }
      var s = Ext.String.format.apply(String, Array.prototype.slice.call(arguments, 1));
      var m = Ext.core.DomHelper.append(this.msgCt, this.createBox(title, s), true);
      m.hide();
      m.slideIn('t').ghost("t", { delay: delay, remove: true});
  },

  createBox: function(t, s){
    if (t) {
      return '<div class="msg"><h3>' + t + '</h3><p>' + s + '</p></div>';
    } else {
      return '<div class="msg"><p>' + s + '</p></div>';
    }
  }
});
