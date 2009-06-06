require 'test_helper'
require 'netzke-core'
class NetzkePreferenceTest < ActiveSupport::TestCase
  test "pref to read-write" do
    p = NetzkePreference
    session = Netzke::Base.session
    session.clear
    
    assert_not_nil(p.pref_to_write(:test))
    p[:test] = "a value"
    assert_not_nil(p.pref_to_read(:test))
  end
  
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
  
  test "multi-user/multi-role support" do
    p = NetzkePreference
    session = Netzke::Base.session
    
    admin_role = Role.create(:name => 'admin')
    user_role = Role.create(:name => 'user')
    
    admin1 = User.create(:login => 'admin1', :role => admin_role)
    user1 = User.create(:login => 'user1', :role => user_role)
    user2 = User.create(:login => 'user2', :role => user_role)

    #
    # assign a value for a role, then read it back by users with the same role
    #
    session.clear
    session[:masq_role] = user_role
    p[:test] = 100

    # first user
    session.clear
    session[:netzke_user] = user1
    assert_equal(100, p[:test])

    # second user
    session.clear
    session[:netzke_user] = user2
    assert_equal(100, p[:test])
    
    #
    # now overwrite the value for user2
    #
    p[:test] = 200
    assert_equal(200, p[:test])
    # .. and check that its still the same for user1
    session.clear
    session[:netzke_user] = user1
    assert_equal(100, p[:test])
    
    #
    # now overwrite it for user1 by means of masq_user
    #
    session.clear
    session[:masq_user] = user1
    p[:test] = 300
    assert_equal(300, p[:test])
    # .. and check it's still the same for user2
    session.clear
    session[:masq_user] = user2
    assert_equal(200, p[:test])
    # .. and that a new user with role 'user' will still read the original value assigned for the role
    user3 = User.create(:login => "user3", :role => user_role)
    session.clear
    session[:netzke_user] = user3
    assert_equal(100, p[:test])
    
  end
end
