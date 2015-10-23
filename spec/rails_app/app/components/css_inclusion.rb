# This component has the header hidden by using some extra styles
class CssInclusion < Netzke::Base
  client_class do |c|
    c.html = "Should not be seen"
    c.title = "CssInclusion component with invisible body"
    c.bodyCls = "require-css" # so we can target this in custom.css
  end

  client_styles do |c|
    c.require :custom
  end
end
