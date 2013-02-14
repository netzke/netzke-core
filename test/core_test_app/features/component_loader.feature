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

  @javascript
  Scenario: Loading component's config
    Given I am on the ComponentLoader test page
    When I press "Config only"
    Then I should see "SimpleComponent (overridden)"

  @javascript
  Scenario: Component autoreloading
    When I go to the SelfReloading test page
    Then I should see panel title saying "Loaded 1 time(s)"
    When I press "Reload"
    Then I should see panel title saying "Loaded 2 time(s)"

  @javascript
  Scenario: Component autoreloading when in container
    Given I am on the ComponentLoader test page
    When I press "Load self reloading"
    And I wait for response from server
    Then I should see panel title saying "Loaded 1 time(s)"
    When I press "Reload"
    And I wait for response from server
    Then I should see panel title saying "Loaded 2 time(s)"
