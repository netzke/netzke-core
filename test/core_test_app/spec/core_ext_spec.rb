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

  it "should jsonify '_meta' to '_meta'" do
    '_meta'.jsonify.should == '_meta'
  end

  it "should jsonify '_meta_data' to '_metaData'" do
    '_meta_data'.jsonify.should == '_metaData'
  end

  it "should jsonify :_meta to :_meta" do
    :_meta.jsonify.should == :_meta
  end
end
