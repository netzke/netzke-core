require 'spec_helper'

feature "Nesting in Rails view", js:true do
  it "should display 2 functional Netzke components at the same time" do
    visit "/simple_rails/multiple_nested?spec=extra__multiple_nested"
    wait_for_javascript
    assert_mocha_results
  end
end
