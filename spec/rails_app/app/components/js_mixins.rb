class JsMixins < Netzke::Base
  js_configure do |c|
    c.foo = 100
    c.mixin :one
    c.mixin :two
  end
end
