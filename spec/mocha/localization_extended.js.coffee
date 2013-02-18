describe "Localization component", ->
  it "should display body", ->
    expectToSee panelWithContent "First property - Second property"

  it "should display title", ->
    expectToSee header "Localized Panel"

  it "should display buttons", ->
    expectToSee button "First action"
    expectToSee button "Second action"
