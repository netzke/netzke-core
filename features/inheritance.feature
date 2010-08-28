Feature: Inheritance
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: Inherited widget should successfully call parent methods in Ruby and JavaScript
    Given I am on the ExtendedServerCaller widget page
    When I press "Call server"
    Then I should see "All quiet here on the server, shiny weather"
    Then I should see "I'm extended server caller"
  
  
  
