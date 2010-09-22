Feature: Aggregation
  In order to value
  As a role
  I want feature

  Scenario: The StaticAggregator component should have 2 aggregatees rendered properly
    When I go to the StaticAggregator test page
    Then I should see "Server Caller"
    And I should see "Extended Server Caller"

  @javascript
  Scenario: The aggregatees in the StaticAggregator should both work properly
    Given I am on the StaticAggregator test page
    When I press "Call server" within "#static_aggregator__center_panel"
    Then I should see "All quiet here on the server"
    And I should not see "All quiet here on the server, shiny weather"
    
    When I press "Call server" within "#static_aggregator__west_panel"
    Then I should see "All quiet here on the server, shiny weather"
  
