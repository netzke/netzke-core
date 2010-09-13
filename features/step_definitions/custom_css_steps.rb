Then /^the body of (.+) widget should not be invisible$/ do |widget|
  widget_id = widget.split("/").map{ |klass| klass.underscore }.join("__")
  page.wait_until{ page.evaluate_script("!Ext.Ajax.isLoading()") }
  page.execute_script(<<-END_OF_JAVASCRIPT).should == false
    return Ext.getCmp('#{widget_id}').body.isVisible();
  END_OF_JAVASCRIPT
end
