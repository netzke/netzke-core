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

  def configure(c)
    c.items = [:server_caller, :hello_world, :extended_server_caller]
    super
  end
end
