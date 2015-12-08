require 'spec_helper'

module Netzke::Core
  describe State do
    it "sets state on 2 different components properly" do
      one = Netzke::Base.new(name: 'one')
      two = Netzke::Base.new(name: 'two')

      one.state[:foo] = 100
      two.state[:bar] = 200

      expect(one.state[:foo]).to eql 100
      expect(two.state[:bar]).to eql 200
    end
  end
end
