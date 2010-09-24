module Netzke
  class ComponentLoader < Component::Base
    def components
      {
        :simple_component => {
          :class_name => "SimpleComponent",
          :title => "Simple Component",
          :lazy_loading => true
        },
        :component_loaded_in_window => {
          :class_name => "SimpleComponent",
          :title => "Component loaded in window",
          :lazy_loading => true
        }
      }
    end
    
    def self.js_properties
      {
        :title => "Component Loader",
        :layout => 'fit',
        :bbar => [{:text => "Load component", :ref => "../button"}, {:text => "Load in window", :ref => "../loadInWindowButton"}],
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            #{js_full_class_name}.superclass.initComponent.call(this);
            
            this.button.on('click', function(){
              this.loadComponent({id: 'simple_component', container: this.getId()});
            }, this);
            
            this.loadInWindowButton.on('click', function(){
              var w = new Ext.Window({width: 500, height: 400, modal: true, layout:'fit'});
              w.show(null, function(){
                this.loadComponent({id: 'component_loaded_in_window', container: w.getId()});
              }, this);
            }, this);
            
          }
        END_OF_JAVASCRIPT
      }
    end
  end
end