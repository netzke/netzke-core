# This component has the header hidden by custom CSS
class ComponentWithCustomCss < Netzke::Base
  js_configure do |c|
    c.html = "A component with the body hidden by means of custom CSS"
    c.title = "ComponentWithCustomCss"
  end

  css_include :custom
  # css_configure do |c|
  #   c.include :custom
  # end
end
