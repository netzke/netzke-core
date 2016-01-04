module Netzke::Core
  class ComponentConfig < DslConfigBase
    def set_defaults!
      self.item_id ||= name
      self.klass ||= self.class_name.try(:constantize) || name.camelize.constantize
    end
  end
end
