# TODO: fix me!
class TabPanel < Netzke::Base
  js_base_class "Ext.TabPanel"
  
  def config
    {
      :active_tab => 0,
      :items => [{
        # Loading a primitive BorderLayoutPanel here
        :class_name => "BorderLayoutPanel",
        :title => "A border layout panel",
        :items => [{
          :title => "I'm NOT a Netzke widget",
          :region => :north,
          :html => "I'm a simple panel",
          :height => 100
        },{
          :class_name => "ServerCaller",
          :region => :center
        },{
          :class_name => "ExtendedServerCaller",
          :region => :west,
          :width => 300,
          :split => true
        }]
      },{
        :class_name => "ExtendedServerCaller"
      }]
    }.deep_merge super
  end
end