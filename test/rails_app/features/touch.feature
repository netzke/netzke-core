Feature: Touch - to be run in Chrome only
  In order to value
  As a role
  I want feature

@javascript
Scenario: Client-server communication
  Given I am on the ServerCaller page for touch
  When I press button "Bug server"
  Then I should see "Hello from the server!"
