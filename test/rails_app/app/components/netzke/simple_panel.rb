module Netzke
  class SimplePanel < Base
    def config
      {
        :title => "SimplePanel",
        :html => "Testik"
      }.deep_merge super
    end
  end
end