class ExtendedComponentWithJsMixin < ComponentWithJsMixin
  js_mixin :some_method_set
  action :action_three

  js_property :title, "ExtendedComponentWithJsMixin"

  def configure
    super
    config.bbar << :action_three
  end
end
