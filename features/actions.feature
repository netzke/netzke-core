Feature: Actions
  In order to value
  As a role
  I want feature

@javascript
Scenario: Pressing button should result in corresponding actions
  When I go to the ComponentWithActions test page
  Then I should see "Disabled action"
  And button "Disabled action" should be disabled
  
  When I press "Some action"
  Then I should see "Some action was triggered"

Scenario: Extending a widget with actions and overriding its bbar
  When I go to the ExtendedComponentWithActions test page
  Then action "another_action" should be disabled


