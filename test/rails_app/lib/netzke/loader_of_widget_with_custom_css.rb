module Netzke
  
  # Loads a widget with custom CSS, to make sure that also dynamically loaded widgets get the correct CSS applied
  class LoaderOfWidgetWithCustomCss < Widget::Base
    def aggregatees
      {
        :widget_with_custom_css => {
          :class_name => "WidgetWithCustomCss",
          :late_aggregation => true
        }
      }
    end
    
    def self.js_properties
      {
        :title => "LoaderOfWidgetWithCustomCss",
        :layout => 'fit',
        :bbar => [{:text => "Load WidgetWithCustomCss", :ref => "../button"}],
        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            #{js_full_class_name}.superclass.initComponent.call(this);
            this.button.on('click', function(){
              this.loadAggregatee({id: 'widget_with_custom_css', container: this.getId()});
            }, this);
          }
        END_OF_JAVASCRIPT
      }
    end
  end
  
end