module Netzke::Core
  class ComponentConfig < DslConfigBase
    def initialize(name, component)
      self.name = name.to_s
    end

    def set_defaults!
      self.item_id ||= name # default item_id
      self.client_config ||= {}
      self.klass ||= name.camelize.constantize # default klass
    end
  end
end
