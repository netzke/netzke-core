# A composite component which has its child components defined inline (as opposed to a using the "component" DSL method explicitely)
class InlineComposite < Netzke::Base
  js_property :layout, :vbox

  # Set width for all
  js_property :defaults, {:width => "100%", :flex => 1}

  items [{
    :class_name => "ServerCaller"
  },{
    :class_name => "ExtendedServerCaller"
  }]
end
