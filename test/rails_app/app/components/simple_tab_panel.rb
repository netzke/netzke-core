class SimpleTabPanel < Netzke::Base
  js_base_class "Ext.TabPanel"
  
  js_property :active_tab, 0
  
  config :items => [{
            # Loading a primitive BorderLayoutPanel here
            :class_name => "BorderLayoutPanel",
            :title => "A border layout panel",
            :items => [{
              :region => :north,
              :height => 100,
              :title => "I'm NOT a Netzke component",
              :html => "I'm a simple panel"
            },{
              :region => :center,
              :class_name => "ServerCaller"
            },{
              :region => :west,
              :width => 300,
              :split => true,
              :class_name => "ExtendedServerCaller"
            }]
        },{
          :class_name => "ExtendedServerCaller"
        }]
end