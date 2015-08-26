module Netzke::Core
  class ComponentConfig < DslConfigBase
    def initialize(name, component)
      self.name = name.to_s
      self.client_config = {}
    end

    def set_defaults!
      self.item_id ||= name
      self.klass ||= self.class_name.try(:constantize) || name.camelize.constantize
    end
  end
end
