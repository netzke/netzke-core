class ConfigurableOnClassLevel < Netzke::Base
  class_attribute :title
  self.title = "Default"

  js_configure do |c|
    c.title = self.title
  end
end
