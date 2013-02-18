describe "Nesting in Rails view", ->
  it "shoud have 2 functional components", (done) ->
    click button "With extended response"
    wait ->
      expectToSee tab "Response from server plus"
      done()
