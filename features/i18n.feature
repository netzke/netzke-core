Feature: I18n
  In order to value
  As a role
  I want feature

@javascript
Scenario: LocalizedPanel should be available in 2 languages
  When I go to the LocalizedPanel test page
  Then I should see "Localized Panel"
  And I should see "First property, Second property"
  And I should see "First action"
  And I should see "Second action"

  When I go to the "es" version of the LocalizedPanel page
  Then I should see "Panel Localizada"
  And I should see "Primera propriedad, Segunda propriedad"
  And I should see "Primera acción"
  And I should see "Segunda acción"

  When I go to the "es" version of the ExtendedLocalizedPanel page
  Then I should see "Panel Localizada"
  And I should see "Primera propriedad, Segunda propriedad"
  And I should see "Action one"
  And I should see "Segunda acción"

  When I go to the "en" version of the ExtendedLocalizedPanel page
  Then I should see "Localized Panel"
  And I should see "First property, Second property"
  And I should see "Action one"
  And I should see "Second action"

  # NOTE: make sure that the locale is restored to "en" in the end!
