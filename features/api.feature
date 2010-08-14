Feature: Client/server communication
  In order to value
  As a role
  I want feature

@selenium
Scenario: Ask server to set our title
  Given I am on the server caller page
  Then I should see "Server Caller"
  
  # When I execute "Ext.getCmp('server_caller').buttons.first().fireEvent('click');"
  When I press "Call server"
  Then I should see "13:62pm"


