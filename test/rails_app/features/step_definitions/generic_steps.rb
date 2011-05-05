Then /^Netzke should be initialized$/ do
  Netzke::Base.should be
end

When /^I execute "([^\"]*)"$/ do |script|
  page.driver.browser.execute_script(script)
end

Then /^button "([^"]*)" should be enabled$/ do |arg1|
  page.driver.browser.execute_script(<<-JS).should == true
  var btn = Array.filter( Ext.ComponentManager.all.getValues(), function(o){ return o.text == '#{arg1}' })[0];
  return typeof(btn)!='undefined' ? !btn.disabled : false
  JS
end

Then /^button "([^"]*)" should be disabled$/ do |arg1|
  page.driver.browser.execute_script(<<-JS).should == true
  var btn = Array.filter( Ext.ComponentManager.all.getValues(), function(o){ return o.text == '#{arg1}' })[0];
  return typeof(btn)!='undefined' ? btn.disabled : false
  JS
end

When /^total requests made should be (\d+)$/ do |count|
  page.driver.browser.execute_script(<<-JS).should == true
    return Netzke.connectionCount == #{count};
  JS
end

When /I sleep (\d+) seconds?/ do |arg1|
  sleep arg1.to_i
end
