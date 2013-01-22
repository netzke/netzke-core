describe "Localization component", ->
  it "should display body in en", ->
    expectToSee panelWithContent "First property - Second property"

  it "should display title in en", ->
    expectToSee headerWithTitle "Localized Panel"

  it "should display buttons in en", ->
    expectToSee buttonWithText "First action"
    expectToSee buttonWithText "Second action"
