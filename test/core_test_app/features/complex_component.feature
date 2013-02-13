Feature: Complex component
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: Complex component must render properly
    When I go to the KindaComplexComponent test page
    Then I should see "Panel One"
    And I should see "Panel Two"
    And I should see "Server Caller"

  @javascript
  Scenario: The last tab of the complex component is a Netzke component that just works
    Given I am on the KindaComplexComponent test page
    When I press "Server Caller"
    And I press "Call server"
    Then I should see "Response from server"
