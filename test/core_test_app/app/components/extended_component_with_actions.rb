class ExtendedComponentWithActions < ComponentWithActions
  js_property :bbar, [:another_action.action]

  # Override actions like this
  def some_action_action(a)
    super
    a.icon = :tick
  end
end
