Then /^Netzke should be initialized$/ do
  Netzke::Base.should be
end

When /^I execute "([^\"]*)"$/ do |script|
  page.driver.browser.execute_script(script)
end

Then /^button "([^"]*)" should be enabled$/ do |arg1|
  page.driver.browser.execute_script(<<-JS).should == true
  var btn = Ext.ComponentMgr.all.filter('text', '#{arg1}').filter('type','button').first();
  return typeof(btn)!='undefined' ? !btn.disabled : false
  JS
end

Then /^button "([^"]*)" should be disabled$/ do |arg1|
  page.driver.browser.execute_script(<<-JS).should == true
  var btn = Ext.ComponentMgr.all.filter('text', '#{arg1}').filter('type','button').first();
  return typeof(btn)!='undefined' ? btn.disabled : false
  JS
end

When /^I sleep 1 second$/ do
  sleep 1
end