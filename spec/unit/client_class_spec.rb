require 'spec_helper'
require_relative './components/basic_component'
require_relative './components/extended_basic_component'
require_relative './components/component_without_extra_code'
require_relative './components/component_with_extensions'

class MyComponent < Netzke::Base
  client_class do |c|
    c.title = "My component"
  end
end

describe Netzke::Core::ClientClassConfig do
  it "allows reading class-level properties" do
    expect(MyComponent.client_class_config.title).to eql "My component"
  end

  it "returns nil when non-existing property is requested" do
    expect(MyComponent.client_class_config.foo).to be_nil
  end

  describe "#expand_client_code_path" do
    it "returns path to script by sym" do
      subject = MyComponent.client_class_config
      subject.dir = "/foo/bar"
      res = subject.expand_client_code_path(:baz)
      expect(res).to eql "/foo/bar/client/baz.js"
    end
  end

  describe "#dir" do
    it "returns path to script files" do
      res = BasicComponent.client_class_config.dir
      expect(res.split("/").last(4)).to eql %w(spec unit components basic_component)
    end
  end

  describe "#properties_as_string" do
    it "allows specifying class properties" do
      res = MyComponent.client_class_config.properties_as_string
      expect(res).to include "My component"
    end
  end

  describe "#override_paths" do
    it "includes default override" do
      res = ComponentWithExtensions.client_class_config.override_paths

      expected = [
        "spec/unit/components/component_with_extensions/client/component_with_extensions.js",
        "spec/unit/components/extension_one/client/extension_one.js",
        "spec/unit/components/extension_two/client/extension_two.js"
      ]

      expect(expected.size).to eql res.size

      res.each_with_index do |filename, i|
        expect(filename).to match /#{expected[i]}/
      end
    end
  end

  describe "#overrides_as_string" do
    it "includes default override" do
      subject = ComponentWithExtensions.client_class_config
      res = subject.overrides_as_string
      expect(res).to include "defaultOverrideMethod"
    end

    it "allows having no override scripts" do
      res = ComponentWithoutExtraCode.client_class_config.overrides_as_string
      expect(res).to be_empty
    end
  end

  describe "extending with modules" do
    it "returns class declaration including overrides" do
      res = ComponentWithExtensions.client_class_config.class_declaration
      expect(res).to include "defaultOverrideMethod"
      expect(res).to include "extensionOneMethod"
      expect(res).to include "extensionTwoMethod"
    end
  end

  describe "inheriting" do
    it "includes overrides (only) from inherited component" do
      res = ExtendedBasicComponent.client_class_config.overrides_as_string
      expect(res).to include "extendedMethod"
      expect(res).to_not include "basicMethod"
    end
  end
end
