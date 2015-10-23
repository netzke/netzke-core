class HasMultipleJsConfigures < Netzke::Base
  client_class do |c|
    c.title = "Original"
    c.some_property = :some_property
  end

  # because this could be done from an included module
  client_class do |c|
    c.title = "Overridden"
    c.another_property = :another_property
  end
end
