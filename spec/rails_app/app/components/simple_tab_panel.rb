class SimpleTabPanel < Netzke::Base
  client_class do |c|
    c.extend = "Ext.tab.Panel"
    c.active_tab = 0
  end

  component :endpoints

  component :hello_world do |c|
    c.excluded = true
  end

  component :endpoints_extended

  component :simple_panel_one do |c|
    c.klass = SimplePanel
  end

  component :simple_panel_two do |c|
    c.klass = SimplePanel
  end

  def configure(c)
    c.items = [:endpoints, :hello_world, :endpoints_extended, :simple_panel_one, :simple_panel_two]
    super
  end
end
