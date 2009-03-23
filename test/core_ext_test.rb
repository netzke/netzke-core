require 'test_helper'
require 'netzke/core_ext'

class CoreExtTest < ActiveSupport::TestCase
  test "to_js" do
    assert_equal({"aProperty" => true}, ActiveSupport::JSON.decode({:a_property => true}.to_js))
    assert_equal({"aProperty" => true}, ActiveSupport::JSON.decode({:a_property => true, :nil_property => nil}.to_js))
    assert_equal([{"aProperty" => true}, {"anotherProperty" => false}], ActiveSupport::JSON.decode([{:a_property => true}, {:another_property => false}].to_js))
    assert_equal([{"aProperty" => true}, {"anotherProperty" =>false}], ActiveSupport::JSON.decode([{:a_property => true, :nil_property => nil}, {:another_property => false}].to_js))
  end
  
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
end