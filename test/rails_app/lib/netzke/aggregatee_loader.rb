module Netzke
  class AggregateeLoader < Widget::Base
    def initial_late_aggregatees
      {
        :simple_panel => {
          :class_name => "SimplePanel"
        }
      }
    end
    
    def self.js_extend_properties
      {
        :title => "Aggregatee Loader",
        :buttons => [{:text => "Load aggregatee", :ref => "../button"}],
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            #{js_full_class_name}.superclass.initComponent.call(this);
            this.button.on('click', function(){
              var win = new Ext.Window({
                layout: 'fit',
                width: 300,
                height: 200
              });
              win.show(null, function(){
                this.loadAggregatee({id: 'simplePanel', container: win.getId()});
              }, this);
            }, this);
          }
        END_OF_JAVASCRIPT
        
      }
    end
  end
end