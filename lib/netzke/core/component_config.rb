module Netzke::Core
  class ComponentConfig < ActiveSupport::OrderedOptions
    def initialize(name, component)
      name = name.to_s

      # TODO: optimize
      self.klass = name.camelize.constantize rescue nil

      self.item_id = name
    end
  end
end
