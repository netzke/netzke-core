module Netzke
  module Routing
    module MapperExtensions
      def netzke
        @set.add_route("/netzke/:action.:format", {:controller => "netzke"})
      end
    end
  end
end