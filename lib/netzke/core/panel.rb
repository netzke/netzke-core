module Netzke
  module Core
    # A very simple panel with an automatically set title. It is used by the framework when no `klass` is specified in a child component declaration, and is not supposed to be used explicitly.
    class Panel < Netzke::Base
      def js_configure(c)
        super
        c.title ||= config.name.to_s.humanize
      end
    end
  end
end
