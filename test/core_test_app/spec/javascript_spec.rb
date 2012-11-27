require 'spec_helper'

describe Netzke::Core::Javascript do
  it "should provide JS config from a component instance" do
    c = Netzke::Core::Panel.new
    c.js_config.should be_present
  end
end
