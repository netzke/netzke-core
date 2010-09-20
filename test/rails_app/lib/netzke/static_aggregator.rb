module Netzke
  class StaticAggregator < Widget::Base
    def config
      {
        # 2 different ways to embed an aggregatee
        :items => [
          # 1 - from the +aggregatees+ method
          js_aggregatee(:center_panel, :region => 'center'),
          
          # 2 - inline (will be conerted into an aggregatee accessible with the +aggregatee+ method)
          {:name => :west_panel, :class_name => "ExtendedServerCaller", :region => 'west', :width => 300, :split => true}
          # js_aggregatee(:west_panel, :region => 'west', :width => 300, :split => true)
        ]
      }.deep_merge super
    end
    
    def aggregatees
      super.merge(
        :center_panel => {
          :class_name => "ServerCaller"
        }
        # :west_panel => {
        #   :class_name => "ExtendedServerCaller"
        # }
      )
    end
    
    def self.js_properties
      {
        :title => "Static Aggregator",
        :layout => 'border'
      }
    end
  end
end