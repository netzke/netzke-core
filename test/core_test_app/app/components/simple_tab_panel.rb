class SimpleTabPanel < Netzke::Base
  js_configure do |c|
    c.extend = "Ext.tab.Panel"
    c.active_tab = 0
  end

  component :server_caller
  component :extended_server_caller

  def items
    [:server_caller, :extended_server_caller]
  end
end
