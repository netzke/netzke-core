describe "Nesting in Rails view", ->
  it "shoud have 2 functional components", (done) ->
    click button "With extended response"
    wait ->
      expectToSee tab "All quiet here on the server indeed"
      done()
