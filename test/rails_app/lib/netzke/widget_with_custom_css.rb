module Netzke
  
  # This widget has the header hidden by custom CSS
  class WidgetWithCustomCss < Widget::Base
    def config
      {
        :title => "WidgetWithCustomCss",
        :unstyled => true,
        :html => "A widget with the header hidden by means of custom CSS"
      }.deep_merge(super)
    end
    
    def self.include_css
      ["#{File.dirname(__FILE__)}/custom.css"]
    end
  end
  
end