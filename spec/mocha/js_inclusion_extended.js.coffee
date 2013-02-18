describe "JsInclusionExtended component", ->
  it "should be able to run included/mixed-in JS code", ->
    click button 'Action three'
    expectToSee header "Modified action three triggered"
