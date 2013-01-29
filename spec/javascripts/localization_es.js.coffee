describe "Localization component in Spanish", ->
  it "should display body", ->
    expectToSee panelWithContent "Primera propriedad - Segunda propriedad"

  it "should display title", ->
    expectToSee header "Panel Localizada"

  it "should display buttons", ->
    expectToSee button "Primera acción"
    expectToSee button "Segunda acción"
