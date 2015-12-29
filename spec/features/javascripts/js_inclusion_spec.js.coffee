describe "JsInclusion component", ->
  it "runs included/mixed-in JS code", ->
    click button 'Action one'
    expectToSee header "Action one triggered"

    click button 'Action two'
    expectToSee header "Action two triggered"

    click button 'Action three'
    expectToSee header "Action three triggered"
