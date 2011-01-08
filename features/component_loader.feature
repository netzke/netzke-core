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

    When I press "Load in window"
    Then I should see "Component loaded in window"

  @selenium
  Scenario: Component loader should invoke a callback
    Given I am on the ComponentLoader test page
    When I press "Load with feedback"
    Then I should see "Callback invoked!"

  @selenium
  Scenario: Component loader should load a window component with another component in it
    Given I am on the ComponentLoader test page
    When I press "Load window with simple component"
    Then I should see "Simple Component Inside Window"
    And I should see "Inner text"

  @selenium
  Scenario: Component loader should load a component with params properly
    Given I am on the ComponentLoader test page
    When I press "Load with params"
    Then I should see "Simple Component with changed HTML"


