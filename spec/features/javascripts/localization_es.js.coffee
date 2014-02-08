describe "Localization component in Spanish", ->
  it "should display title", ->
    expectToSee header "Panel Localizada"

  it "should display buttons", ->
    expectToSee button "Primera acción"
    expectToSee button "Segunda acción"

  it "should display body", ->
    click button 'Muestra propriedades'
    expectToSee header "Primera propriedad - Segunda propriedad"
