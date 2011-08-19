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
end
