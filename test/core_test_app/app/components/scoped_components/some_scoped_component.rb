module ScopedComponents
  class SomeScopedComponent < Netzke::Base
    js_configure do |c|
      c.title = "Some Scoped Component Title"
      c.html = "Some Scoped Component HTML"
    end
  end
end
