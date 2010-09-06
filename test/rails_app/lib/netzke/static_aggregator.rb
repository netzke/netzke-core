module Netzke
  class StaticAggregator < Widget::Base
    def default_config
      super.merge(
        :items => [
          aggregatee_js_config(:center_panel, :region => 'center'), 
          aggregatee_js_config(:west_panel, :region => 'west', :width => 300, :split => true)
        ]
      )
    end
    
    def aggregatees
      {
        :center_panel => {
          :class_name => "ServerCaller"
        },
        :west_panel => {
          :class_name => "ExtendedServerCaller"
        }
      }
    end
    
    def self.js_properties
      {
        :title => "Static Aggregator",
        :layout => 'border'
      }
    end
  end
end