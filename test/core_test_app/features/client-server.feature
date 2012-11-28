Feature: Client/server communication
  In order to value
  As a role
  I want feature

@selenium
Scenario: Ask server to set our title
  Given I am on the ServerCaller test page
  Then I should see "Server Caller"

  When I press "Call server"
  And I wait for response from server
  Then I should see "All quiet here on the server"

@selenium
Scenario: Calling an endpoint with callback and scope
  Given I am on the ServerCaller test page
  When I press "Call with generic callback and scope"
  Then I should see "Fancy title set!"
