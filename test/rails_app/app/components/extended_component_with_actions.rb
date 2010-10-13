class ExtendedComponentWithActions < ComponentWithActions
  def config
    {
      :bbar => [:another_action.action]
    }.deep_merge super
  end
end