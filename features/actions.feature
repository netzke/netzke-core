Feature: Actions
  In order to value
  As a role
  I want feature

@focus @javascript
Scenario: Pressing button should result in corresponding actions
  When I go to the WidgetThatHasActions widget page
  Then I should see "Disabled action"
  And button "Disabled action" should be disabled
  
  When I press "Some action"
  Then I should see "Some action was triggered"


