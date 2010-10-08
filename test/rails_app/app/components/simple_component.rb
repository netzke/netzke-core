class SimpleComponent < Netzke::Base
  def config
    {
      :title => "SimpleComponent",
      :html => "Inner text"
    }.deep_merge super
  end
end