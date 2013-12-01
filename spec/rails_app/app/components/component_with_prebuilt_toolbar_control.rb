class ComponentWithPrebuiltToolbarControl < Netzke::Base
  js_configure do |c|
    c.mixin
  end

  action :some_action

  def configure(c)
    super
    c.bbar = [ :some_action, "Date:", :prebuilt_control ]
  end
end
