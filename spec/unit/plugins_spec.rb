require 'spec_helper'

class FooPlugin < Netzke::Plugin
end

class ComponentWithPlugin < Netzke::Base
  plugin :foo_plugin
end

describe Netzke::Core::Plugins do
  it "eagerly loads plugins" do
    expect(ComponentWithPlugin.new.eagerly_loaded_components).to include(:foo_plugin)
  end
end
