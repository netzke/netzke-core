require 'test_helper'
require 'netzke-core'
class NetzkePreferenceTest < ActiveSupport::TestCase
  test "basic values" do
    an_integer = 1976
    a_float = 1976.1345
    a_symbol = :a_symbol
    a_true = true
    a_false = false
    a_nil = nil
    a_hash = {"a" => an_integer, "b" => a_true, "c" => nil, "d" => a_float}
    an_array = [1, "a", a_hash, [1,3,4], a_true, a_false, a_nil, a_float]
    

    p = NetzkePreference
    p[:a_hash] = a_hash
    p["an_integer"] = an_integer
    p[:a_true] = a_true
    p[:a_false] = a_false
    p[:a_nil] = a_nil
    p[:an_array] = an_array
    p[:a_symbol] = a_symbol
    p[:a_float] = a_float
    
    assert_equal(a_hash, p[:a_hash])
    assert_equal(an_integer, p[:an_integer])
    assert_equal(a_true, p[:a_true])
    assert_equal(a_false, p[:a_false])
    assert_equal(an_array, p[:an_array])
    assert_equal(a_nil, p[:a_nil])
    assert_equal(a_symbol, p[:a_symbol])
    assert_equal(a_float, p[:a_float])
    
    assert_equal(nil, p[:non_existing])
  end
  
  test "multiuser support" do
    admin_role = Role.create(:name => 'admin')
    user_role = Role.create(:name => 'user')
    
    User.create(:login => 'admin1', :role => admin_role)
    User.create(:login => 'user1', :role => user_role)
    
    Netzke::Base.session[:masq_role] = user_role
    assert_equal(true, false)
  end
end
