describe "Actions component", ->
  it "should handle clicking a button", ->
    click button "Simple action"
    expectToSee header "Simple action triggered"

  it "should show certain buttons disabled", ->
    expectDisabled button "Disabled action"

  it "should not show buttons for excluded actions", ->
    expectToNotSee button "Excluded action"

  it "handles actionless button click", ->
    click button "Actionless button"
    expectToSee header "Actionless button was clicked"
