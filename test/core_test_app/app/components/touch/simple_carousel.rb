module Touch
  class SimpleCarousel < Netzke::Base
    js_base_class "Ext.Carousel"

    js_properties(
      :fullscreen => true,
      :docked_items => [{:dock => :top, :xtype => :toolbar, :title => 'Carousel Toolbar'}]
    )

    def configuration
      super.merge({:items => [:panel_one.component, :panel_two.component]})
    end

    component :panel_one, :class_name => "Touch::ServerCaller", :html => "ServerCaller One"
    component :panel_two, :class_name => "Touch::ServerCaller", :html => "ServerCaller Two"
  end
end
