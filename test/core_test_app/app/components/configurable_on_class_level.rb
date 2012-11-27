class ConfigurableOnClassLevel < Netzke::Base
  class_attribute :awesome
  self.awesome = false

  js_configure do |c|
    puts "!!! self.awesome: #{self.awesome.inspect}"
  end
end
