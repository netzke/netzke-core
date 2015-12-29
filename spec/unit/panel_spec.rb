require 'spec_helper'

class MyPanel < Netzke::Core::Panel
end

describe Netzke::Core::Panel do
  it "should set default title based on its name" do
    panel = MyPanel.new(name: 'just_panel')
    expect(panel.config.title).to eql "Just panel"
  end
end
