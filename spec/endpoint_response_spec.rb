require 'spec_helper'

describe Netzke::Core::EndpointResponse do
  it "should allow to mimick calling methods on client side" do
    this = Netzke::Core::EndpointResponse.new

    this.set_title("Title")
    this.set_title.should == ["Title"]
  end

  it "should allow assigning values directly" do
    this = Netzke::Core::EndpointResponse.new

    this.result = 42
    this.result.should == 42
  end
end
