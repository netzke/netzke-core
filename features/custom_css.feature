Feature: Custom css
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: A component with a hidden body should not show show its body
    When I go to the ComponentWithCustomCss test page
    Then I should see "ComponentWithCustomCss"
    But  the body of ComponentWithCustomCss component should not be invisible
  
  @javascript
  Scenario: A dynamically loaded component with a hidden body should not display its body
    When I go to the LoaderOfComponentWithCustomCss test page
    And I press "Load ComponentWithCustomCss"
    Then I should see "ComponentWithCustomCss"
    But  the body of LoaderOfComponentWithCustomCss/ComponentWithCustomCss component should not be invisible
