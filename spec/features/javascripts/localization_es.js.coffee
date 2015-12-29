describe "Localization component in Spanish", ->
  it "displays title", ->
    expectToSee header "Panel Localizada"

  it "displays buttons", ->
    expectToSee button "Primera acción"
    expectToSee button "Segunda acción"

  it "displays body", ->
    click button 'Muestra propriedades'
    expectToSee header "Primera propriedad - Segunda propriedad"
