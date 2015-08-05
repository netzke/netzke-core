require 'spec_helper'

describe Netzke::Core::Actions do
  class Foo < Netzke::Base
    action :foo

    def configure(c)
      super
      c.bbar = [:foo]
    end
  end

  class Bar < Netzke::Base
    action :bar do |a|
      a.text = "BAR"
    end

    def configure(c)
      super
      c.bbar = [:bar]
    end
  end

  it "configures action via DSL with defaults" do
    actions = Foo.new.actions
    expect(actions.keys).to eql([:foo])
    expect(actions[:foo].keys).to include(:name, :text, :tooltip)
  end

  it "configures action via DSL" do
    actions = Bar.new.actions
    expect(actions.keys).to eql([:bar])
    expect(actions[:bar].keys).to include(:name, :text, :tooltip)
    expect(actions[:bar][:text]).to eql "BAR"
  end
end
