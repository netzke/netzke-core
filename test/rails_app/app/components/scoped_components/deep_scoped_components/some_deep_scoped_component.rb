module ScopedComponents
  module DeepScopedComponents
    class SomeDeepScopedComponent < ScopedComponents::SomeScopedComponent
      js_properties :title => "Some Deep Scoped Component Title", :html => "Some Deep Scoped Component HTML"
    end
  end
end