require 'test_helper'
require 'netzke/core_ext'

class CoreExtTest < ActiveSupport::TestCase
  test "recursive delete if nil" do
    assert_equal({:a => 1, :b => {:c => 4, :d => 5}}, {:a => 1, :aa => nil, :b => {:c => 4, :d => 5, :cc => nil}}.recursive_delete_if_nil)

    assert_equal({:a => [{:e => 5}, {:f => 7}], :b => {:c => 4, :d => 5}}, {:a => [{:e => 5, :ee => nil},{:f => 7, :ff => nil}], :aa => nil, :b => {:c => 4, :d => 5, :cc => nil}}.recursive_delete_if_nil)

    assert_equal([
      {:a => [{:e => 5}]}, 
      {}, 
      {:b => {:c => 4, :d => 5}}
    ], [
      {:a => [{:e => 5, :ee => nil}]}, 
      {:aa => nil}, 
      {:b => {:c => 4, :d => 5, :cc => nil}}
    ].recursive_delete_if_nil)
  end
  
  test "convert keys" do
    assert_equal([
      {:aB => 1, :cDD => [{:lookMa => true},{:wowNow => true}]}
    ],[:a_b => 1, :c_d_d => [{:look_ma => true},{:wow_now => true}]].convert_keys{|k| k.camelize(:lower)})
  end
  
  test "javascript-like access to hash data" do
    a = {}
    a["key"] = 100
    assert_equal(100, a.key)
    
    a.key = 200
    assert_equal(200, a["key"])
    
    a.another_key = 300
    assert_equal(300, a[:another_key])
  end
  
  test "jsonify" do
    assert_equal({:aB => 1, "cD" => [[1, {:eF => "stay_same"}], {"literal_symbol" => :should_not_change, "literal_string".l => "also_should_not"}]}, {:a_b => 1, "c_d" => [[1, {:e_f => "stay_same"}], {:literal_symbol.l => :should_not_change, "literal_string".l => "also_should_not"}]}.jsonify)
  end
  
end