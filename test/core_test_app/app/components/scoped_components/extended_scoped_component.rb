module ScopedComponents
  class ExtendedScopedComponent < SomeScopedComponent
    js_configure do |c|
      c.title = "Extended Scoped Component Title"
      c.html = "Extended Scoped Component HTML"
    end
  end
end
