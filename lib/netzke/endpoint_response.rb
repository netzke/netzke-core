module Netzke
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
