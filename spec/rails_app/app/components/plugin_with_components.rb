class PluginWithComponents < Netzke::Plugin
  component :simple_window do |c|
    c.width = 300
    c.height = 200
    c.title = "Window added by PluginWithComponents"
  end
end
