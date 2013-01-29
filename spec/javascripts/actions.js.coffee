describe "Actions component", ->
  it "should handle clicking a button", ->
    click buttonWithText "Simple action"
    expectToSee headerWithTitle "Simple action triggered"

  it "should show certain buttons disabled", ->
    expectDisabled buttonWithText "Disabled action"

  it "should not show buttons for excluded actions", ->
    expectToNotSee buttonWithText "Excluded action"
