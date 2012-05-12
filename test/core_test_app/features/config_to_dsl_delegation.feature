Feature: Config to dsl delegation
  In order to value
  As a role
  I want feature

@javascript
Scenario: A base components delegates its configuration options to DSL
  When I go to the DslDelegatedProperties test page
  Then I should see "Title set via DSL"
  And I should see "HTML set via DSL"
