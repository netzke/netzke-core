class Netzke::Core::JsonLiteral < String
  def as_json(options = nil) self end #:nodoc:
  def encode_json(encoder) self end #:nodoc:
end
