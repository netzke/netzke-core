require 'spec_helper'

describe "Nesting in Rails view" do
  it "should display 2 functional Netzke components at the same time" do
    visit "/simple_rails/multiple_nested?spec='extra__multiple_nested'"
    wait_for_javascript
    assert_mocha_results
  end
end
