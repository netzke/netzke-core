require 'spec_helper'

class MyPanel < Netzke::Core::Panel
end

describe Netzke::Core::Panel do
  it "should set default title based on its name" do
    panel = MyPanel.new(name: 'just_panel')
    panel.config.title.should == "Just panel"
  end
end
