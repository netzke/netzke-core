class DynamicTabPanel < Netzke::Base
  js_base_class "Ext.TabPanel"
  js_mixin

  action :add_tab

  def default_config
    super.tap do |c|
      c[:items] = [{
        :title => "Tab One"
      }]

      c[:bbar] = [:add_tab.action]
    end
  end

  component :tab_two, :class_name => "SimplePanel", :title => "Tab Two (dynamic)", :lazy_loading => true

end
