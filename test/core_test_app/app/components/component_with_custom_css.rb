# This component has the header hidden by custom CSS
class ComponentWithCustomCss < Netzke::Base
  js_property :html, "A component with the body hidden by means of custom CSS"

  css_include :custom

  def configure
    super
    config.title = "ComponentWithCustomCss"
  end
end
