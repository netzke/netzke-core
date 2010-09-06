module Netzke
  module ScopedWidgets
    class SomeScopedWidget < Netzke::Widget::Base
      def self.js_properties
        {
          :title => "Some Scoped Widget Title",
          :html => "Some Scoped Widget HTML"
        }
      end
    end
  end
end