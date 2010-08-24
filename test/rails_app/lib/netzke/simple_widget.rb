module Netzke
  class SimpleWidget < Widget::Base
    def default_config
      super.merge({
        :ext_config => {
          :title => "SimpleWidget",
          :html => "Inner text"
        }
      })
    end
  end
end