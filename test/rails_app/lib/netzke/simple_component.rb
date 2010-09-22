module Netzke
  class SimpleComponent < Component::Base
    def config
      {
        :title => "SimpleComponent",
        :html => "Inner text"
      }.deep_merge super
    end
  end
end