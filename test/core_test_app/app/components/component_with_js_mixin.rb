class ComponentWithJsMixin < Netzke::Base
  js_include :extra_one, :extra_two
  js_mixin :method_set_one, :method_set_two
  js_mixin # with no parameters, it'll assume :component_with_js_mixin

  action :action_one
  action :action_two
  action :action_three

  def configure
    super
    config.bbar = [:action_one, :action_two, :action_three]
    config.title = "ComponentWithJsMixin"
  end
end
