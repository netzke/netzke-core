describe "Persistence", ->
  it "sets persistent title", (done) ->
    expectToSee header "Default title"
    click button "Set state"
    wait ->
      done()
