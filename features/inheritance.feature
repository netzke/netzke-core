Feature: Inheritance
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: Inherited widget should successfully call parent methods in Ruby and JavaScript
    When I go to the ExtendedServerCaller test page
    Then I should see "Extended Server Caller"
    When I press "Call server"
    Then I should see "All quiet here on the server, shiny weather"
  
  Scenario: Extended scoped widgets should render
    Given I am on the ScopedWidgets::ExtendedScopedWidget test page
    Then I should see "Extended Scoped Widget Title"
    And I should see "Extended Scoped Widget HTML"
  