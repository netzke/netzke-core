/**
 * Class creating simple notifications. Borrowed from http://dev.sencha.com/extjs/5.1.0/examples/shared/examples.js
 * @class Netzke.Notifier
 */
Ext.define('Netzke.Notifier', function(){
  var msgCt;

  function createBox(t, s){
    return t ?
      '<div class="msg ' + Ext.baseCSSPrefix + 'border-box"><h3>' + t + '</h3><p>' + s + '</p></div>'
    :
      '<div class="msg ' + Ext.baseCSSPrefix + 'border-box"><p>' + s + '</p></div>';
  }


  return {
    /**
     * Shows notification on the screen.
     * @method msg
     * @param {String} msg Notification body HTML
     * @param {Object} options May contain the following keys:
     *
     *   * **title** - title of notification
     *   * **delay** (ms) - time notification should stay on the screen
     */
    msg: function(msg, options){
      if (options == undefined) options = {};

      if (Ext.isArray(msg)) {
        msg = msg.join("<br>")
      }

      if (msgCt) {
        document.body.appendChild(msgCt.dom);
      } else {
        msgCt = Ext.DomHelper.append(document.body, {id:'msg-div'}, true);
      }
      var m = Ext.DomHelper.append(msgCt, createBox(options.title, msg), true);
      m.hide();
      m.slideIn('t').ghost("t", { delay: options.delay || Netzke.Core.NotificationDelay, remove: true});
    }
  };
});
