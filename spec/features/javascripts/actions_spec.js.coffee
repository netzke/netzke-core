describe "Actions component", ->
  it "handles clicking a button", ->
    click button "Simple action"
    expectToSee header "Simple action triggered"

  it "shows certain buttons disabled", ->
    expectDisabled button "Disabled action"

  it "does not show buttons for excluded actions", ->
    expectToNotSee button "Excluded action"

  it "handles actionless button click", ->
    click button "Actionless button"
    expectToSee header "Actionless button was clicked"
