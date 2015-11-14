module Routing
  class TopLevel < Netzke::Base
    component :one do |c|
      c.klass = Routing::One
    end

    component :two do |c|
      c.klass = Routing::Two
    end

    action :load_one
    action :load_two
    action :load_one_one
    action :load_one_two

    def configure(c)
      super
      c.title = "TopLevel"
      c.bbar = [:load_one, :load_two, :load_one_one, :load_one_two]
    end
  end
end
