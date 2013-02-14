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

When /^I press tool "([^"]*)"$/ do |tool|
  id = page.driver.browser.execute_script(<<-JS)
    var toolCmp;
    Ext.ComponentManager.all.each(function(k,v){
      if (v.type == '#{tool}') {
        toolCmp = v;
        return false;
      }
    });
    return toolCmp.getId();
  JS

  find("##{id} img").click
end

Then /^tab panel should have tab with title "(.*?)"$/ do |arg1|
  page.driver.browser.execute_script(<<-JS).should == true
    var tabPanel = Ext.ComponentQuery.query('tabpanel')[0];
    return !!tabPanel.down('[title="#{arg1}"]');
  JS
end

Then /^tab panel should not have tab with title "(.*?)"$/ do |arg1|
  page.driver.browser.execute_script(<<-JS).should == true
    var tabPanel = Ext.ComponentQuery.query('tabpanel')[0];
    return !tabPanel.down('[title="#{arg1}"]');
  JS
end

When /^I wait for response from server$/ do
  page.wait_until{ page.driver.browser.execute_script("return !Netzke.ajaxIsLoading()") }
end

When /I sleep (\d+) seconds?/ do |arg1|
  sleep arg1.to_i
end

Then /^I should see panel title saying "(.*?)"$/ do |title|
  page.driver.browser.execute_script(<<-JS).should == true
    return Ext.ComponentQuery.query('header[title="#{title}"]').length > 0;
  JS
end
