Feature: Scopes
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: Scoped components should render
    Given I am on the ScopedComponents::SomeScopedComponent test page
    Then I should see "Some Scoped Component Title"
    And I should see "Some Scoped Component HTML"

    When I go to the ScopedComponents::DeepScopedComponents::SomeDeepScopedComponent test page
    Then I should see "Some Deep Scoped Component Title"
    And I should see "Some Deep Scoped Component HTML"
