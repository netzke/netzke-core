module Netzke
  class StaticAggregator < Widget::Base
    def default_config
      super.merge(
        :items => [{
          :region => 'center',
          :xtype => "netzkeservercaller",
        }.merge(aggregatee_instance(:center_panel).js_config),{
          :region => 'west',
          :xtype => "netzkeextendedservercaller",
          :width => 300,
          :split => true
        }.merge(aggregatee_instance(:west_panel).js_config)]
      )
    end
    
    def initial_aggregatees
      {
        :center_panel => {
          :class_name => "ServerCaller"
        },
        :west_panel => {
          :class_name => "ExtendedServerCaller"
        }
      }
    end
    
    def self.js_extend_properties
      {
        :title => "Static Aggregator",
        :layout => 'border'
      }
    end
  end
end