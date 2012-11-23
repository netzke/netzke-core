require 'spec_helper'

module Netzke::Core
  describe ActionConfig do
    it "should preserve localized attributes from superclass if those are not overridden" do
      sc = ServerCaller.new
      esc = ExtendedServerCaller.new
      sc.actions[:bug_server].text.should == "Call server"
      esc.actions[:bug_server].text.should == "Call server"

      sc.actions[:bug_server].tooltip.should == "This bugs server"
      esc.actions[:bug_server].tooltip.should == "This bugs server in its own way"
    end
  end
end
