Feature: Component loader
  In order to value
  As a role
  I want feature

  @selenium
  Scenario: Component loader should be able to load an component
    Given I am on the ComponentLoader test page
    When I press "Load component"
    Then I should see "Inner text"
    And I should see "Simple Component"
  
  
  
