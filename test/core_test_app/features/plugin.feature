Feature: Plugin
  In order to value
  As a role
  I want feature

@javascript
Scenario: Plugin calling its server part
  Given I am on the PanelWithPlugin test page
  When I press tool "gear"
  Then I should see "Server response"

@javascript
Scenario: Plugin inserting its action into component
  Given I am on the PanelWithPlugin test page
  When I press "Action one"
  Then I should see "Action one triggered"
