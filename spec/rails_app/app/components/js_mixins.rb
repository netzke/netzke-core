class JsMixins < Netzke::Base
  client_class do |c|
    c.mixin :one
    c.mixin :two
  end
end
