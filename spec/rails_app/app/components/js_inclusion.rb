class JsInclusion < Netzke::Base
  js_configure do |c|
    c.require :extra_one, :extra_two
    c.mixin :method_set_one, :method_set_two
    c.mixin # by default it assumes :js_inclusion
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
