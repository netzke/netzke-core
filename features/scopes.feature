Feature: Scopes
  In order to value
  As a role
  I want feature

  Scenario: Scoped widgets should render
    Given I am on the ScopedWidgets::SomeScopedWidget test page
    Then I should see "Some Scoped Widget Title"
    And I should see "Some Scoped Widget HTML"

    When I go to the ScopedWidgets::DeepScopedWidgets::SomeDeepScopedWidget test page
    Then I should see "Some Deep Scoped Widget Title"
    And I should see "Some Deep Scoped Widget HTML"
  
  
  
