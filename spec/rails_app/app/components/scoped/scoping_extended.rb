module Scoped
  class ScopingExtended < Scoping
    def configure(c)
      super
      c.title = c.title + " extended"
    end
  end
end
