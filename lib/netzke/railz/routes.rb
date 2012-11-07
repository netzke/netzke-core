module ActionDispatch::Routing
  class Mapper
    # Enable routes for Netzke assets and endpoint calls. By default the URL is "/netzke", but this can be changed by providing an argument:
    #
    #     netzke "/some/path/netzke"
    def netzke(prefix = "/netzke")
      match "#{prefix}/:action(.:format)", to: "netzke#", as: 'netzke'
    end
  end
end
