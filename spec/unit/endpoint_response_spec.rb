require 'spec_helper'

describe Netzke::Core::EndpointResponse do
  it "should allow to mimick calling methods on client side" do
    client = Netzke::Core::EndpointResponse.new

    client.set_title("Title")
    client.set_title.should == ["Title"]
  end

  it "should allow assigning values directly" do
    client = Netzke::Core::EndpointResponse.new

    client.result = 42
    client.result.should == 42
  end
end
