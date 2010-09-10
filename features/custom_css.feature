Feature: Custom css
  In order to value
  As a role
  I want feature

  Scenario: A widget with hidden header should not display its header
    When I go to the WidgetWithCustomCss test page
    Then I should see "A widget with the header hidden by means of custom CSS"
    But  the header of WidgetWithCustomCss widget should be invisible
  
