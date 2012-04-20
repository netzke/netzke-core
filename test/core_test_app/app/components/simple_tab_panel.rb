class SimpleTabPanel < Netzke::Base
  js_base_class "Ext.TabPanel"
  js_property :active_tab, 0

  component :server_caller
  component :extended_server_caller
end
