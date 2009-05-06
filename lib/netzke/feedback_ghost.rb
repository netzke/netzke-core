module Netzke
  #
  # An invisible component that provides feedback service for all Netzke widgets
  #
  class FeedbackGhost < Base
    def self.js_base_class
      "Ext.Component" # yes, invisible
    end

    def self.js_extend_properties
      {
        :show_feedback => <<-JS.l,
          function(msg){
            var createBox = function(s, l){
                return ['<div class="msg">',
                        '<div class="x-box-tl"><div class="x-box-tr"><div class="x-box-tc"></div></div></div>',
                        '<div class="x-box-ml"><div class="x-box-mr"><div class="x-box-mc">', s, '</div></div></div>',
                        '<div class="x-box-bl"><div class="x-box-br"><div class="x-box-bc"></div></div></div>',
                        '</div>'].join('');
            }

            var showBox = function(msg, lvl){
              if (!lvl) {lvl = 'notice'};
              var msgCt = Ext.DomHelper.insertFirst(document.body, {'class':'netzke-feedback'}, true);
              var m = Ext.DomHelper.append(msgCt, {html:createBox(msg,lvl)}, true);
              m.slideIn('t').pause(2).ghost("b", {remove:true});
            }

            if (typeof msg != 'string') {
              var compoundMsg = "";
              Ext.each(msg, function(m){
                compoundMsg += m.msg + '<br>';
              });
              if (compoundMsg != "") showBox(compoundMsg, null); // the second parameter will be level
            } else {
              showBox(msg);
            }
        	}
        JS
      }
    end
  end
end