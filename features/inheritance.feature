Feature: Inheritance
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: Inherited component should successfully call parent methods in Ruby and JavaScript
    When I go to the ExtendedServerCaller test page
    Then I should see "Extended Server Caller"
    When I press "Call server"
    Then I should see "All quiet here on the server, shiny weather"
    And I should see "Added by extended Server Caller"
  
  Scenario: Extended scoped components should render
    Given I am on the ScopedComponents::ExtendedScopedComponent test page
    Then I should see "Extended Scoped Component Title"
    And I should see "Extended Scoped Component HTML"
  