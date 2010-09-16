module Netzke
  class SimplePanel < Widget::Base
    def default_config
      super.merge(
        :title => "SimplePanel",
        :html => "Testik"
      )
    end
  end
end