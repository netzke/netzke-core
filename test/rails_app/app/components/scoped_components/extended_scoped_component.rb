module ScopedComponents
  class ExtendedScopedComponent < SomeScopedComponent
    def self.js_properties
      {
        :title => "Extended Scoped Component Title",
        :html => "Extended Scoped Component HTML"
      }
    end
  end
end