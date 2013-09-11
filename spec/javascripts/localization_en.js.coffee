describe "Localization component", ->
  it "should display title", ->
    expectToSee header "Localized Panel"

  it "should display buttons", ->
    expectToSee button "First action"
    expectToSee button "Second action"

  it "should display body", ->
    click button 'Show properties'
    expectToSee header "First property - Second property"
