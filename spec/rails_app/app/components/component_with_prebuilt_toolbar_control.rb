class ComponentWithPrebuiltToolbarControl < Netzke::Base
  js_configure

  action :some_action

  def configure(c)
    super
    c.bbar = [ :some_action, "Date:", :prebuilt_control ]
  end
end
