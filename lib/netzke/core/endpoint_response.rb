module Netzke::Core
  # Represents the endpoint response at the server side. Collects instructions for the client-side object. Accessible as
  # the `client` in the endpoint calls, e.g.:
  #
  #       class SimpleComponent < Netzke::Base
  #         endpoint :whats_up_server do
  #           client.set_title("Response from server")
  #         end
  #       end
  class EndpointResponse < ::Hash
    def method_missing(name, *params)
      if name.to_s =~ /(.+)=$/
        self[$1.to_sym] = params.first
      else
        self[name] = self.class.new if self[name].nil?
        self[name] = params if params.present?
        self[name]
      end
    end
  end
end
