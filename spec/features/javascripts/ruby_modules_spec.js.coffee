describe "RubyModules component", ->
  it "contains declared tabs", ->
    expectToSee tab "Panel One"
    expectToSee tab "Panel Two"
    expectToSee tab "Endpoints"

  it "has a functional Netzke component", (done) ->
    click tab "Endpoints"
    click button "With response"
    wait ->
      expectToSee tab "Hello world"
      done()

  it "executes client methods from BasicStuff module", ->
    click button "Some action"
    expectToSee tab "Action triggered"
    click button "Another action"
    expectToSee tab "Another action triggered"
