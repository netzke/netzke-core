require 'spec_helper'

class Foo < Netzke::Base
  action :foo_action
end

class FooExt < Foo
end

module Netzke::Core
  describe ActionConfig do
    it "should preserve localized attributes from superclass if those are not overridden" do
      sc = Foo.new
      esc = FooExt.new
      sc.actions[:foo_action].text.should == "Foo"
      esc.actions[:foo_action].text.should == "Foo plus"

      sc.actions[:foo_action].tooltip.should == "Foo!"
      esc.actions[:foo_action].tooltip.should == "Foo plus!"
    end
  end
end
