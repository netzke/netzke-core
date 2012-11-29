Feature: Actions
  In order to value
  As a role
  I want feature

@javascript
Scenario: Pressing button should result in corresponding actions
  When I go to the ComponentWithActions test page
  Then I should not see "Excluded action"
  Then I should see "Disabled action"
  And button "Disabled action" should be disabled

  When I press "Some Cool Action"
  Then I should see "Some action was triggered"

@javascript
Scenario: Pressing a tool should result in corresponding action
  Given I am on the PanelWithTools test page
  When I press tool "gear"
  Then I should see "Gear clicked"
  When I press tool "refresh"
  Then I should see "Refresh clicked"
