describe "RubyModules component", ->
  it "should contain declared tabs", ->
    expectToSee tab "Panel One"
    expectToSee tab "Panel Two"
    expectToSee tab "Endpoints"

  it "should have a functional Netzke component", (done) ->
    click tab "Endpoints"
    click button "With response"
    wait ->
      expectToSee tab "Response from server"
      done()
