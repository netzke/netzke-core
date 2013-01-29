module Scoped
  module DeeplyScoped
    class Scoping < Scoped::Scoping
      def configure(c)
        super
        c.title = c.title + " extended in DeeplyScoped"
      end
    end
  end
end
