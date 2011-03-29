Then /^the body of (.+) component should not be invisible$/ do |component|
  component_id = component.split("/").map{ |klass| klass.underscore }.join("__")
  page.wait_until{ page.evaluate_script("!Ext.Ajax.isLoading()") }
  page.execute_script(<<-JS).should == false
    return Ext.getCmp('#{component_id}').body.isVisible();
  JS
end
