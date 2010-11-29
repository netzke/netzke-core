class ComponentWithJsMixin < Netzke::Base
  js_property :title, "ComponentWithJsMixin"
  js_include :extra_one, :extra_two
  js_mixin :method_set_one, :method_set_two
  action :action_one
  action :action_two
  js_property :bbar, [:action_one.action, :action_two.action]
end
