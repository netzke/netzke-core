require 'spec_helper'
describe "Core extensions" do
  it "should properly do netzke_deep_map" do
    {a: [1,2,{b:3},{c:[4,5]}], d: 6}.netzke_deep_map{|el| el.is_a?(Hash) ? el.merge(e:7) : el + 10}.should == { a: [11,12,{e:7, b:3},{e:7, c:[14,15]}], d: 6}
  end

  it "should strip js comments" do
    "var test;//commment".strip_js_comments.should == "var test;"
  end

  it "should not strip // in strings" do
    'var someVar = "abc//def";'.strip_js_comments.should == 'var someVar="abc//def";'
  end
end
