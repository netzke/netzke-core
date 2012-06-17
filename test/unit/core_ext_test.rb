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
    assert_equal({:a => 1, :b => {:bb => 2}}, {"a" => 1, "b" => {"bb" => 2}}.deep_convert_keys{ |k| k.to_sym })
    assert_equal([{"a" => 1}, {"b" => {"bb" => 2}}], [{:a => 1}, {:b => {:bb => 2}}].deep_convert_keys{ |k| k.to_s })

    assert_equal([
      {:aB => 1, :cDD => [{:lookMa => true},{:wowNow => true}]}
    ],[:a_b => 1, :c_d_d => [{:look_ma => true},{:wow_now => true}]].deep_convert_keys{|k| k.to_s.camelize(:lower).to_sym})
  end

  test "jsonify" do
    assert_equal({:aB => 1, "cD" => [[1, {:eF => "stay_same"}], {"literal_symbol" => :should_not_change, "literal_string".l => "also_should_not"}]}, {:a_b => 1, "c_d" => [[1, {:e_f => "stay_same"}], {:literal_symbol.l => :should_not_change, "literal_string".l => "also_should_not"}]}.jsonify)
  end

  test "flatten_with_type" do
    test_flatten_with_type = {
      :one => 1,
      :two => 2.5,
      :three => {
        :four => true,
        :five => {
          :six => "a string"
        }
      }
    }.flatten_with_type

    assert_equal(4, test_flatten_with_type.size)

    test_flatten_with_type.each do |i|
      assert([{
        :name => :one, :value => 1, :type => :Fixnum
      },{
        :name => :two, :value => 2.5, :type => :Float
      },{
        :name => :three__four, :value => true, :type => :Boolean
      },{
        :name => :three__five__six, :value => "a string", :type => :String
      }].include?(i))
    end
  end

end
