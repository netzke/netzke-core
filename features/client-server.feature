Feature: Client/server communication
  In order to value
  As a role
  I want feature

@selenium
Scenario: Ask server to set our title
  Given I am on the ServerCaller widget page
  Then I should see "Server Caller"
  
  # When I execute "Ext.getCmp('server_caller').buttons.first().fireEvent('click');"
  When I press "Call server"
  Then I should see "All quiet here on the server"


