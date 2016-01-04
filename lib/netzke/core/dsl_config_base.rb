module Netzke::Core
  # Base for ActionConfig, ComponentConfig, etc
  class DslConfigBase < ActiveSupport::OrderedOptions
    def initialize(name, component)
      @component = component
      @name = self.name = name.to_s
    end
  end
end
