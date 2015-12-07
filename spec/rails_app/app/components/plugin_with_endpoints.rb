class PluginWithEndpoints < Netzke::Plugin
  client_class do |c|
  end

  endpoint :on_gear do
    client.process_gear_callback("Response from server side of PluginWithEndpoints")
  end
end
