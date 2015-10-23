require 'spec_helper'
require_relative './components/javascript_spec_components'

describe Netzke::Core::ClientCode do
  it "provides JS config from a component instance" do
    c = Netzke::Core::Panel.new
    c.js_config.should be_present
  end

  it "evaluates client_class class-level block late" do
    ConfigurableOnClassLevel.title = "Overridden"
    ConfigurableOnClassLevel.client_class_config.title.should == "Overridden"
  end

  it "evaluates all client_class blocks" do
    c = HasMultipleJsConfigures.client_class_config
    c.title.should == "Overridden"
    expect(c.some_property).to eql :some_property
    expect(c.another_property).to eql :another_property
  end
end
