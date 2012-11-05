class ExtendedComponentWithJsMixin < ComponentWithJsMixin
  js_configure do |c|
    c.mixin :some_method_set
  end

  def configure(c)
    super
    c.title = "ExtendedComponentWithJsMixin"
  end
end
