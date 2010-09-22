Feature: Composition
  In order to value
  As a role
  I want feature

  Scenario: The StaticComposite component should have 2 components rendered properly
    When I go to the StaticComposite test page
    Then I should see "Server Caller"
    And I should see "Extended Server Caller"

  @javascript
  Scenario: The components in the StaticComposite should both work properly
    Given I am on the StaticComposite test page
    When I press "Call server" within "#static_aggregator__center_panel"
    Then I should see "All quiet here on the server"
    And I should not see "All quiet here on the server, shiny weather"
    
    When I press "Call server" within "#static_aggregator__west_panel"
    Then I should see "All quiet here on the server, shiny weather"
  
