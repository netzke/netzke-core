module Netzke
  class SimpleWidget < Widget::Base
    def config
      {
        :title => "SimpleWidget",
        :html => "Inner text"
      }.deep_merge super
    end
  end
end