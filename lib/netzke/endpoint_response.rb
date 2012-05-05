module Netzke
  class EndpointResponse < ::Hash
    def method_missing(name, *params)
      self[name] = self.class.new if self[name].nil?
      self[name] = params if params.present?
      self[name]
    end
  end
end
