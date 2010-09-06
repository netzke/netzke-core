module Netzke
  module ScopedWidgets
    class ExtendedScopedWidget < SomeScopedWidget
      def self.js_properties
        {
          :title => "Extended Scoped Widget Title",
          :html => "Extended Scoped Widget HTML"
        }
      end
    end
  end
end