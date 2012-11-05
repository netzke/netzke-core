require 'spec_helper'
describe "Core extensions" do
  it "should properly do deep_each_pair" do
    res = {}
    {
      :one => 1,
      :two => {:three => 3},
      :nine => [
        {:four => 4, :five => {:six => 6}},
        {:seven => [{:eight => 8}]}
      ]
    }.deep_each_pair{ |k,v| res[k] = v }
    res.should == {:one => 1, :three => 3, :four => 4, :six => 6, :eight => 8}
  end

  it "should properly do deep_map" do
    {a: [1,2,{b:3},{c:[4,5]}], d: 6}.deep_map{|el| el.is_a?(Hash) ? el.merge(e:7) : el + 10}.should == { a: [11,12,{e:7, b:3},{e:7, c:[14,15]}], d: 6}
  end
end
