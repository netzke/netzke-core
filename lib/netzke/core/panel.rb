module Netzke
  module Core
    # A very simple panel with an automatically set title. Can be used as a child component +klass+.
    class Panel < Netzke::Base
      def configure(c)
        c.title ||= name.to_s.humanize
        super
      end
    end
  end
end
