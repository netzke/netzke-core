module Netzke
  module ScopedComponents
    class SomeScopedComponent < Netzke::Component::Base
      def self.js_properties
        {
          :title => "Some Scoped Component Title",
          :html => "Some Scoped Component HTML"
        }
      end
    end
  end
end