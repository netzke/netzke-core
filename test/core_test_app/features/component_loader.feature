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
  Scenario: Component loader should invoke a callback in loadComponent
    Given I am on the ComponentLoader test page
    When I press "Load with feedback"
    Then I should see "Callback invoked!"

  @selenium
  Scenario: Component loader should invoke a generic endpoint callback
    Given I am on the ComponentLoader test page
    When I press "Load with generic callback"
    Then I should see "Generic callback invoked!"

  @selenium
  Scenario: Component loader should invoke a generic endpoint callback
    Given I am on the ComponentLoader test page
    When I press "Load with generic callback and scope"
    Then I should see "Fancy title set!"

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

  @javascript
  Scenario: Component loader should report that it can't load a component and stay adequate
    Given I am on the ComponentLoader test page
    When I press "Non-existing component"
    Then I should see "Couldn't load component 'non_existing_component'"
    And I should not see "Loading"

  @javascript
  Scenario: Component loader not be able to load a component marked as excluded
    Given I am on the ComponentLoader test page
    When I press "Inaccessible"
    Then I should see "Couldn't load component 'inaccessible'"
