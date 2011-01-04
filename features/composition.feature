Feature: Composition
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: The SomeComposite component should have 2 components rendered properly
    When I go to the SomeComposite test page
    Then I should see "Server Caller"
    And I should see "Extended Server Caller"

  @javascript
  Scenario: The components in the SomeComposite should both work properly
    Given I am on the SomeComposite test page
    When I press "Call server" within "#some_composite__center_panel"
    Then I should see "All quiet here on the server"
    And I should not see "All quiet here on the server, shiny weather"

    When I press "Call server" within "#some_composite__west_panel"
    Then I should see "All quiet here on the server, shiny weather"

  @javascript
  Scenario: Server should be able to address (deeply) nested components
    Given I am on the SomeComposite test page
    When I press "Update west from server"
    And I sleep 1 second
    Then I should see "Here's an update for west panel"

    When I press "Update east south from server"
    Then I should see "Here's an update for south panel in east panel"


