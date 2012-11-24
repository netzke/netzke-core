Feature: File inclusion
  In order to value
  As a role
  I want feature

@javascript
Scenario: A component with external JS file included
  Given I am on the ComponentWithRequiredJs test page
  When I press "Print message"
  Then I should see "Some message shown in the body"
