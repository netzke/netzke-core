require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

module Netzke
  describe State do
    it "should be possible to save component's state" do
      component = Base.new(:name => 'some_component', :persistence => true)
      component.state.should == {}

      component.update_state(:value_to_remember, 42)
      component.state.should == {:value_to_remember => 42}

      component.update_state(:more_to_remember => "a string", :and_yet_more => "another string")
      component.state.should == {:value_to_remember => 42, :more_to_remember => "a string", :and_yet_more => "another string"}

    end
  end
end
