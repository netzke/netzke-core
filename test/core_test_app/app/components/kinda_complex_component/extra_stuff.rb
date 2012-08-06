class KindaComplexComponent < Netzke::Base
  module ExtraStuff
    extend ActiveSupport::Concern

    included do
      component :server_caller
    end

    # Let's add another tab with a Netzke component in it
    def configure(c)
      super
      c.items += [{ netzke_component: :server_caller }]
    end
  end
end
