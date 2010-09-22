module Netzke
  
  # Loads a component with custom CSS, to make sure that also dynamically loaded components get the correct CSS applied
  class LoaderOfComponentWithCustomCss < Component::Base
    def aggregatees
      {
        :component_with_custom_css => {
          :class_name => "ComponentWithCustomCss",
          :late_aggregation => true
        }
      }
    end
    
    def self.js_properties
      {
        :title => "LoaderOfComponentWithCustomCss",
        :layout => 'fit',
        :bbar => [{:text => "Load ComponentWithCustomCss", :ref => "../button"}],
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            #{js_full_class_name}.superclass.initComponent.call(this);
            this.button.on('click', function(){
              this.loadAggregatee({id: 'component_with_custom_css', container: this.getId()});
            }, this);
          }
        END_OF_JAVASCRIPT
      }
    end
  end
  
end