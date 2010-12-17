module ActionDispatch::Routing
  class Mapper
    def netzke
      match "/netzke/:action(.:format)" => "netzke"
    end
  end
end