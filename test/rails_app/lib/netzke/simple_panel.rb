module Netzke
  class SimplePanel < Widget::Base
    def default_config
      super.merge({
        :ext_config => {
          :html => "Inner text"
        }
      })
    end
  end
end