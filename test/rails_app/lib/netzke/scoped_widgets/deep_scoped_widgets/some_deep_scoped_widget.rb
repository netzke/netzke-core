module Netzke
  module ScopedWidgets
    module DeepScopedWidgets
      class SomeDeepScopedWidget < Netzke::ScopedWidgets::SomeScopedWidget
        def self.js_properties
          {
            :title => "Some Deep Scoped Widget Title",
            :html => "Some Deep Scoped Widget HTML"
          }
        end
      end
    end
  end
end