# This component has the header hidden by custom CSS
class ComponentWithCustomCss < Netzke::Base
  def config
    {
      :title => "ComponentWithCustomCss",
      :html => "A component with the header hidden by means of custom CSS"
    }.deep_merge(super)
  end
  
  def self.include_css
    ["#{File.dirname(__FILE__)}/custom.css"]
  end
end