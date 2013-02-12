class RubyModules < Netzke::Base
  module ExtraStuff
    extend ActiveSupport::Concern

    included do
      component :endpoints
    end

    # Let's add another tab with a Netzke component in it
    def configure(c)
      super
      c.items += [:endpoints]
    end
  end
end
