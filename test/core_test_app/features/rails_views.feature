Feature: Rendering components in the Rails views
  In order to value
  As a role
  I want feature

@javascript
Scenario: Rendering multiple complex components in a view
  Given I am on the "multiple_nested" view

  When I press "Call server"
  And I wait for response from server
  Then I should see "All quiet here on the server"

  When I press "Call server extensively"
  And I wait for response from server
  Then I should see "All quiet here on the server, shiny weather"
