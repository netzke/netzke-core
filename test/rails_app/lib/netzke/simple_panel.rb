module Netzke
  class SimplePanel < Widget::Panel
    def default_config
      super.merge(
        :title => "SimplePanel",
        :html => "Testik"
      )
    end
  end
end