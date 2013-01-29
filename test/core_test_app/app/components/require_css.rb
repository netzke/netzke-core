# This component has the header hidden by using some extra styles
class RequireCss < Netzke::Base
  js_configure do |c|
    c.html = "Should not be seen"
    c.title = "RequireCss component with invisible body"
    c.bodyCls = "require-css" # so we can target this in custom.css
  end

  css_configure do |c|
    c.require :custom
  end
end
