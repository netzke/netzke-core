class Plugins < Netzke::Base
  plugin :plugin_with_actions
  plugin :plugin_with_endpoints
  plugin :plugin_with_components

  js_configure do |c|
    c.title = "Plugins component"
  end
end
