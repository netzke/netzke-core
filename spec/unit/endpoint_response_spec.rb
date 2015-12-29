require 'spec_helper'

describe Netzke::Core::EndpointResponse do
  it "allows to mimick calling methods on client side" do
    client = Netzke::Core::EndpointResponse.new

    client.set_title("Title")
    expect(client.set_title).to eql ["Title"]
  end

  it "allows assigning values directly" do
    client = Netzke::Core::EndpointResponse.new

    client.result = 42
    expect(client.result).to eql 42
  end
end
