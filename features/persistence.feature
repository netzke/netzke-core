Feature: Persistence
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: The component with persistence should be able to store and retrieve a persistence setting
    When I go to the ComponentWithSessionPersistence test page
    Then I should see "Default Title"
    And I should see "Default HTML"
    But I should not see "Title From Session"
    And I should not see "HTML from session"

    When I press "Tell server to store new title"
    And I go to the ComponentWithSessionPersistence test page
    Then I should see "Title From Session"
    And I should see "HTML from session"

