class SimpleTabPanel < Netzke::Base
  js_configure do |c|
    c.extend = "Ext.tab.Panel"
    c.active_tab = 0
  end

  component :server_caller
  component :hello_world do |c|
    c.excluded = true
  end
  component :extended_server_caller

  component :simple_panel_one do |c|
    c.klass = SimplePanel
  end

  component :simple_panel_two do |c|
    c.klass = SimplePanel
  end

  def configure(c)
    c.items = [:server_caller, :hello_world, :extended_server_caller, :simple_panel_one, :simple_panel_two]
    super
  end
end
