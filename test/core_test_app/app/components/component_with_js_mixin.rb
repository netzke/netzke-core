class ComponentWithJsMixin < Netzke::Base
  js_configure do |c|
    c.include :extra_one, :extra_two
    c.mixin :method_set_one, :method_set_two
    c.mixin # with no parameters, it'll assume :component_with_js_mixin
  end

  action :action_one
  action :action_two
  action :action_three

  def configure
    super
    config.bbar = [:action_one, :action_two, :action_three]
    config.title = "ComponentWithJsMixin"
  end
end
