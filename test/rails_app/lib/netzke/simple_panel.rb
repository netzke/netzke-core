module Netzke
  class SimplePanel < Widget::Base
    def config
      {
        :title => "SimplePanel",
        :html => "Testik"
      }.deep_merge super
    end
  end
end