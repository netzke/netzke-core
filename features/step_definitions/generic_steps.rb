Then /^Netzke should be initialized$/ do
  Netzke::Base.should be
end

When /^I execute "([^\"]*)"$/ do |script|
  page.driver.browser.execute_script(script)
end

Then /^button "([^\"]*)" should be disabled$/ do |arg1|
  pending
end

When /^I sleep 1 second$/ do
  sleep 1
end