require 'spec_helper'

module Netzke::Core
  describe State do
    it "should be possible to save component's state" do
      Netzke::Base.session = {} # mimick session

      component = Netzke::Base.new(:name => 'some_component', :persistence => true)

      component.state[:value_to_remember] = 42
      component.state.to_hash.should == {"value_to_remember" => 42}

      component.state[:more_to_remember] = "a string"
      component.state[:and_yet_more] = "another string"

      component.state.to_hash.should == {"value_to_remember" => 42, "more_to_remember" => "a string", "and_yet_more" => "another string"}
    end
  end
end
