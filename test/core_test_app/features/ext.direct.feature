Feature: Actions
  In order to value
  As a role
  I want feature

@javascript
Scenario: Updating 3 components (in one request)
  Given I go to the ExtDirect::Composite test page
  When I fill in "User:" with "Power User"
  And I press "Update"
  Then I should see "Details for user Power User"
  And I should see "Statistics for user Power User"
