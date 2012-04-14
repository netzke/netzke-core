class ExtendedComponentWithJsMixin < ComponentWithJsMixin
  js_mixin :some_method_set
  action :action_three

  js_property :title, "ExtendedComponentWithJsMixin"
  js_property :bbar, superclass.js_properties[:bbar] + [:action_three]
end
