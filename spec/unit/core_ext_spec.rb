require 'spec_helper'
describe "Core extensions" do
  it "performs netzke_deep_map" do
    expect({a: [1,2,{b:3},{c:[4,5]}], d: 6}.netzke_deep_map{|el| el.is_a?(Hash) ? el.merge(e:7) : el + 10}).to eql(a: [11,12,{e:7, b:3},{e:7, c:[14,15]}], d: 6)
  end

  it "performs netzke_deep_replace" do
    input = {
      a: {replace: true, foo: 1},
      b: {
        foo: {replace: true, foo: 2}
      },
      c: [{d: 1}, {replace: true}, 3]
    }
    res = input.netzke_deep_replace do |el|
      el.is_a?(Hash) && el[:replace] ? {replacement: true} : el
    end

    expect(res).to eql(
      a: {replacement: true},
      b: {
        foo: {replacement: true}
      },
      c: [{d: 1}, {replacement: true}, 3]
    )
  end
end
