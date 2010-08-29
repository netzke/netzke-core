Feature: Aggregatee loader
  In order to value
  As a role
  I want feature

  @selenium
  Scenario: Aggregatee loader should be able to load an aggregatee
    Given I am on the AggregateeLoader widget page
    When I press "Load aggregatee"
    Then I should see "Inner text"
    And I should see "Simple Widget"
  
  
  
