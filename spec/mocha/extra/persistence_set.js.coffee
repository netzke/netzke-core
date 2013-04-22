describe "Persistence", ->
  it "should set persistent title", (done) ->
    expectToSee header "Default title"
    click button "Set state"
    wait ->
      done()
