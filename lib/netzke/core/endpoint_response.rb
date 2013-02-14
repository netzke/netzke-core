module Netzke::Core
  # Represents the endpoint response at the server side.
  # An instance of it is passed as the second parameter to the +endpoint+ block.
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
