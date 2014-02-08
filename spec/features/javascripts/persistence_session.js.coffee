describe "Persistence component", ->
  it "should set and retrieve a session variable", (done) ->
    click button "Retrieve session variable"
    wait ->
      expectToSee header "Session variable: not set"

    click button "Set session variable"
    wait ->
      click button "Retrieve session variable"
      wait ->
        expectToSee header "Session variable: set"
        done()
