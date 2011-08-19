Feature: JsMixins
  In order to value
  As a role
  I want feature

  @javascript
  Scenario: ComponentWithJsMixin should behave
    Given I am on the ComponentWithJsMixin test page
    When I press "Action one"
    Then I should see "Action One triggered!"
    When I press "Action two"
    Then I should see "Action Two triggered!"
    When I press "Action three"
    Then I should see "Action Three triggered!"

  @javascript
  Scenario: ExtendedComponentWithJsMixin should behave, too
    Given I am on the ExtendedComponentWithJsMixin test page
    When I press "Action three"
    Then I should see "Action Three triggered!"
