module ScopedComponents
  class SomeScopedComponent < Netzke::Base
    def self.js_properties
      {
        :title => "Some Scoped Component Title",
        :html => "Some Scoped Component HTML"
      }
    end
  end
end