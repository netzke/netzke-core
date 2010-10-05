module Netzke
  class SimpleComponent < Base
    def config
      {
        :title => "SimpleComponent",
        :html => "Inner text"
      }.deep_merge super
    end
  end
end