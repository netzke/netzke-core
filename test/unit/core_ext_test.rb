require 'test_helper'
require 'netzke/core_ext'

class CoreExtTest < ActiveSupport::TestCase
  test "jsonify" do
    assert_equal({:aB => 1, "cD" => [[1, {:eF => "stay_same"}], {"literal_symbol" => :should_not_change, "literal_string".l => "also_should_not"}]}, {:a_b => 1, "c_d" => [[1, {:e_f => "stay_same"}], {:literal_symbol.l => :should_not_change, "literal_string".l => "also_should_not"}]}.jsonify)
  end
end
