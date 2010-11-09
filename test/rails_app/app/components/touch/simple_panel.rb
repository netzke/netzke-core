module Touch
  class SimplePanel < Netzke::Base
    js_base_class "Ext.Panel"

    js_properties(
      :fullscreen => true,
      :docked_items => [{:dock => :top, :xtype => :toolbar, :title => 'A toolbar', :items => [{:text => "Button 1"}, {:text => "Button 2"}]}],
      :layout => {:type => :hbox, :align => :stretch},
      :defaults => {:flex => 1}
    )

    config :items => [{:xtype => :carousel, :items => [{:html => "Panel One"}, {:html => "Panel Two"}]}]
  end
end
