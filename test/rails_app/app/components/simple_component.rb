module Netzke
class SomeComponent < Base
  action :action_one
  action :action_two
  action :action_three do
    {:text => "Action three"}
  end
  
  js_property :bbar, [:action_one.action, :action_two.action]

  def config
    {
      :tbar => [:action_three.action]
    }
  end

  # def actions
  #   super.deep_merge({
  #     :action_four => {:text => "Action 4"}
  #   })
  # end
  
  action :action_five, :text => "Action 5"
end

class ExtendedComponent < SomeComponent
  js_property :bbar, [:action_one.action, :action_two.action, :action_three.action, :action_four.action, :action_five.action]
  js_property :tbar, [:action_one.action, :action_two.action, :action_three.action, :action_four.action, :action_five.action]
end

class AnotherExtendedComponent < ExtendedComponent
  action :action_one, :text => "Action 1"
  action :action_five, :text => "Action Five"
  
  action :action_two do
    super().merge :disabled => true, :text => super()[:text] + ", extended"
  end
  
  action :action_three do
    {:text => "Action 3"}
  end
end

class YetAnotherExtendedComponent < AnotherExtendedComponent
  action :action_two, :disabled => false
end
end

class SimpleComponent < Netzke::Base
  js_properties :title => "SimpleComponent", 
                :html  => "Inner text"
end

