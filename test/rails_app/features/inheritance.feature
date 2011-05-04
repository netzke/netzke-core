Feature: Inheritance
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: Inherited component should successfully call parent methods in Ruby and JavaScript
    When I go to the "en" version of the ExtendedServerCaller page
    Then I should see "Extended Server Caller"
    When I press "Call server extensively"
    Then I should see "All quiet here on the server, shiny weather"
    And I should see "Added by extended Server Caller"

  @javascript
  Scenario: Extended scoped components should render
    Given I am on the ScopedComponents::ExtendedScopedComponent test page
    Then I should see "Extended Scoped Component Title"
    And I should see "Extended Scoped Component HTML"
