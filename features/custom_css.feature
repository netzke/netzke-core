Feature: Custom css
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: A widget with a hidden body should not show show its body
    When I go to the WidgetWithCustomCss test page
    Then I should see "WidgetWithCustomCss"
    But  the body of WidgetWithCustomCss widget should not be invisible
  
  @javascript
  Scenario: A dynamically loaded widget with a hidden body should not display its body
    When I go to the LoaderOfWidgetWithCustomCss test page
    And I press "Load WidgetWithCustomCss"
    Then I should see "WidgetWithCustomCss"
    But  the body of LoaderOfWidgetWithCustomCss/WidgetWithCustomCss widget should not be invisible
