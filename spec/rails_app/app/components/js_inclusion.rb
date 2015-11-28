class JsInclusion < Netzke::Base
  client_class do |c|
    c.require :extra_one, :extra_two
    c.include :method_set_one, :method_set_two
  end

  action :action_one
  action :action_two
  action :action_three

  def configure(c)
    super
    c.bbar = [:action_one, :action_two, :action_three]
    c.title = "JsInclusion component"
  end
end
