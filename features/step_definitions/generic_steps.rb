Then /^Netzke should be initialized$/ do
  Netzke::Widget::Base.should be
end

When /^I execute "([^\"]*)"$/ do |script|
  page.driver.browser.execute_script(script)
end

Then /^button "([^"]*)" should be disabled$/ do |arg1|
  Netzke.should be # PENDING!
end
