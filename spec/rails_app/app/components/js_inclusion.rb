class JsInclusion < Netzke::Base
  client_class do |c|
    c.require :extra_one, :extra_two
    c.include :method_set_one
    c.include "#{Rails.root}/app/components/shared/method_set_two.js"
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
