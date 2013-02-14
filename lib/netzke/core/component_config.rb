module Netzke::Core
  class ComponentConfig < ActiveSupport::OrderedOptions
    def initialize(name)
      self.name = name.to_s
    end

    def set_defaults!
      self.item_id ||= name # default item_id
      self.klass ||= name.camelize.constantize # default klass
    end
  end
end
