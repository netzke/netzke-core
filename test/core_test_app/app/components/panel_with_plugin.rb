class PanelWithPlugin < Netzke::Base
  plugin :some_plugin do |c|
    c.klass = SomePlugin
  end

  plugin :plugin_with_components do |c|
    c.klass = PluginWithComponents
  end
end
