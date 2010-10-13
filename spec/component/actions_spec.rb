require File.dirname(__FILE__) + '/../spec_helper'
require 'netzke-core'

describe Netzke::Actions do
  it "should be possible to override toolbars without overriding action settings" do
    ExtendedComponentWithActions.new.actions[:another_action][:disabled].should == true
  end
end  
