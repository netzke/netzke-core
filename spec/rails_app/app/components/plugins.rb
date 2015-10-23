class Plugins < Netzke::Base
  plugin :plugin_with_actions
  plugin :plugin_with_endpoints
  plugin :plugin_with_components

  client_class do |c|
    c.title = "Plugins component"
  end
end
