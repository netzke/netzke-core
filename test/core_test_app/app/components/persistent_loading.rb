# Subsequent loading of tabs should result in functional "tab" component instances
class PersistentLoading < Netzke::Base
  js_configure do |c|
    c.extend = "Ext.tab.Panel"
    c.mixin
  end

  action :persistent_tab
  action :temporary_tab

  component :tab do |c|
    c.klass = Endpoints
  end

  def configure(c)
    super
    c.bbar = [:persistent_tab, :temporary_tab]
  end
end
