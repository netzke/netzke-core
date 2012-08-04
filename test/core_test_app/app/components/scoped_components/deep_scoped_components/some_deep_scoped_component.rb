module ScopedComponents
  module DeepScopedComponents
    class SomeDeepScopedComponent < ScopedComponents::SomeScopedComponent
      js_configure do |c|
        c.title = "Some Deep Scoped Component Title"
        c.html = "Some Deep Scoped Component HTML"
      end
    end
  end
end
