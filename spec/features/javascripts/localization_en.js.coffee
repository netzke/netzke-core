describe "Localization component", ->
  it "display title", ->
    expectToSee header "Localized Panel"

  it "displays buttons", ->
    expectToSee button "First action"
    expectToSee button "Second action"

  it "displays body", ->
    click button 'Show properties'
    expectToSee header "First property - Second property"
