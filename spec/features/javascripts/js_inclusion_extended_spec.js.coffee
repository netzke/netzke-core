describe "JsInclusionExtended component", ->
  it "runs included/mixed-in JS code", ->
    click button 'Action three'
    expectToSee header "Modified action three triggered"
