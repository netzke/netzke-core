class ExtendedComponentWithJsMixin < ComponentWithJsMixin
  js_configure do |c|
    c.mixin :some_method_set
  end

  def configure
    super
    config.title = "ExtendedComponentWithJsMixin"
  end
end
