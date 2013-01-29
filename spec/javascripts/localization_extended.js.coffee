describe "Localization component", ->
  it "should display body", ->
    expectToSee panelWithContent "First property - Second property"

  it "should display title", ->
    expectToSee headerWithTitle "Localized Panel"

  it "should display buttons", ->
    expectToSee buttonWithText "First action"
    expectToSee buttonWithText "Second action"
