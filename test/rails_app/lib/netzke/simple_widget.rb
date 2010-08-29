module Netzke
  class SimpleWidget < Widget::Base
    def default_config
      super.deep_merge(
        :title => "SimpleWidget",
        :html => "Inner text"
      )
    end
  end
end