module Netzke::Support
  def self.permit_hash_params(params)
    return params unless params
    return params unless params.respond_to? :to_unsafe_h
    params.to_unsafe_h
  end
end
