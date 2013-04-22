module Scoped
  class Scoping < Netzke::Base
    def configure(c)
      super
      c.title = "Scoping component"
    end
  end
end
