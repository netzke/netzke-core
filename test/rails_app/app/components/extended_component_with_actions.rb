class ExtendedComponentWithActions < ComponentWithActions
  js_property :bbar, [:another_action.action]

  action :some_action, :icon => :tick
end