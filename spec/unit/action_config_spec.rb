require 'spec_helper'

class Foo < Netzke::Base
  action :foo
end

class FooExt < Foo
end

module Netzke::Core
  describe ActionConfig do
    it "preserves localized attributes from superclass if those are not overridden" do
      sc = Foo.new
      esc = FooExt.new
      expect(sc.actions[:foo].text).to eql "Foo"
      expect(esc.actions[:foo].text).to eql "Foo plus"

      expect(sc.actions[:foo].tooltip).to eql "Foo!"
      expect(esc.actions[:foo].tooltip).to eql "Foo plus!"
    end
  end
end
