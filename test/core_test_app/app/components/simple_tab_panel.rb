class SimpleTabPanel < Netzke::Base
  js_base_class "Ext.TabPanel"
  js_property :active_tab, 0

  component :server_caller
  component :extended_server_caller

  def items
    [{netzke_component: :server_caller}, {netzke_component: :extended_server_caller}]

    # TODO: make this reality:
    #[:server_caller, :extended_server_caller]
  end
end
