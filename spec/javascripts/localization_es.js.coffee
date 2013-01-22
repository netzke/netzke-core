describe "Localization component in Spanish", ->
  it "should display body", ->
    expectToSee panelWithContent "Primera propriedad - Segunda propriedad"

  it "should display title", ->
    expectToSee headerWithTitle "Panel Localizada"

  it "should display buttons", ->
    expectToSee buttonWithText "Primera acción"
    expectToSee buttonWithText "Segunda acción"
