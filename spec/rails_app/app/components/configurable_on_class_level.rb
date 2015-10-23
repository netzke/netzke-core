class ConfigurableOnClassLevel < Netzke::Base
  class_attribute :title
  self.title = "Default"

  client_class do |c|
    c.title = self.title
  end
end
