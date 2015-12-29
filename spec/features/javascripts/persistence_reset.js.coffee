describe "Persistence", ->
  it "resets persistent title", (done) ->
    expectToSee header "Title from state"
    click button "Reset state"
    wait ->
      done()
