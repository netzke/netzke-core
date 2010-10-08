class SimplePanel < Netzke::Base
  def config
    {
      :title => "SimplePanel",
      :html => "Testik"
    }.deep_merge super
  end
end