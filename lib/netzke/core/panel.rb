module Netzke
  module Core
    # A very simple panel with an automatically set title. Can be used as a child component +klass+.
    class Panel < Netzke::Base
      def js_configure(c)
        super
        c.title ||= config.name.to_s.humanize
      end
    end
  end
end
