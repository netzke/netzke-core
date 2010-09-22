module Netzke
  class ComponentLoader < Component::Base
    def components
      {
        :simple_component => {
          :class_name => "SimpleComponent",
          :title => "Simple Component",
          :lazy_loading => true
        }
      }
    end
    
    def self.js_properties
      {
        :title => "Component Loader",
        :layout => 'fit',
        :bbar => [{:text => "Load component", :ref => "../button"}],
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            #{js_full_class_name}.superclass.initComponent.call(this);
            this.button.on('click', function(){
              this.loadComponent({id: 'simple_component', container: this.getId()});
            }, this);
          }
        END_OF_JAVASCRIPT
        
      }
    end
  end
end