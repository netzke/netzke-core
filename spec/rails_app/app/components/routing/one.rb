module Routing
  class One < Netzke::Base
    client_class do |c|
      c.title = "One"
      c.layout = :fit
    end

    component :one_one do |c|
      c.klass = Routing::OneOne
    end

    component :one_two do |c|
      c.klass = Routing::OneTwo
    end
  end
end
