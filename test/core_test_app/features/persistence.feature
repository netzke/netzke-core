Feature: Persistence
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: The component with persistence should be able to store and retrieve a persistence setting
    When I go to the StatefulComponent test page
    Then I should see "Default Title"
    And I should see "Default HTML"
    But I should not see "Title From State"
    And I should not see "HTML from session"

    When I press "Set session and state"
    And I wait for response from server
    And I go to the StatefulComponent test page
    Then I should see "Title From State"
    And I should see "HTML from session"

    When I press "Reset session and state"
    And I wait for response from server
    And I go to the StatefulComponent test page
    Then I should see "Default Title"
    And I should see "Default HTML"
    But I should not see "Title From State"
    And I should not see "HTML from session"

  @javascript
  Scenario: Sharing persistence key
    When I go to the StatefulComponent test page
    And I press "Set session and state"
    And I wait for response from server
    And I go to the StatefulComponentWithSharedState test page
    Then I should see "Title From State"
