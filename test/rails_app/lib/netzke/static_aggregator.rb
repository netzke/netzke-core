module Netzke
  class StaticAggregator < Widget::Base
    def config
      {
        :items => [
          js_aggregatee(:center_panel, :region => 'center'), 
          js_aggregatee(:west_panel, :region => 'west', :width => 300, :split => true)
        ]
      }.deep_merge super
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