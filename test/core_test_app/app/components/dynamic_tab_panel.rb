class DynamicTabPanel < Netzke::Base
  js_base_class "Ext.TabPanel"
  js_mixin

  action :add_tab

  def configure
    super
    config.items = [{
      :title => "Tab One"
    }]

    config.bbar = [:add_tab]
  end

  component :tab_two, :class_name => "SimplePanel", :title => "Tab Two (dynamic)", :lazy_loading => true
end
