require 'spec_helper'
require_relative './components/javascript_spec_components'

describe Netzke::Core::ClientCode do
  it "provides JS config from a component instance" do
    c = Netzke::Core::Panel.new
    expect(c.js_config).to be_present
  end

  it "evaluates client_class class-level block late" do
    ConfigurableOnClassLevel.title = "Overridden"
    expect(ConfigurableOnClassLevel.client_class_config.title).to eql "Overridden"
  end

  it "evaluates all client_class blocks" do
    c = HasMultipleJsConfigures.client_class_config
    expect(c.title).to eql "Overridden"
    expect(c.some_property).to eql :some_property
    expect(c.another_property).to eql :another_property
  end
end
