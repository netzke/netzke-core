class ComponentWithJsMixin < Netzke::Base
  js_property :title, "ComponentWithJsMixin"
  js_mixin :some_method_set
  js_mixin :another_method_set
  action :action_one
  action :action_two
  js_property :bbar, [:action_one.action, :action_two.action]
end
