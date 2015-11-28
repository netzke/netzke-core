class JsMixins < Netzke::Base
  client_class do |c|
    c.include :one
    c.include :two
  end
end
