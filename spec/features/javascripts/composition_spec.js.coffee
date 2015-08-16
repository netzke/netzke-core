describe "Composition component", ->
  it "should have 4 nested components", ->
    expectToSee header "Endpoints"
    expectToSee header "Endpoints Extended"
    expectToSee header "A panel"
    expectToSee header "Another panel"

  it "should not show excluded component", ->
    expectToNotSee header "Should not be seen"

  it "should have properly working nested components", (done) ->
    click button "With response"
    wait().then ->
      expectToSee header "Hello world"
      click button "With extended response"
      wait()
    .then ->
      expectToSee header "Hello world plus"
      done()

  it "as server, should be able to address (deeply) nested components", (done) ->
    click button "Update west from server"
    wait().then ->
      expectToSee header "Here's an update for west panel"
      click button "Update east south from server"
      wait()
    .then ->
      expectToSee header "Here's an update for south panel in east panel"
      done()

  it "should instantiate a pre-loaded component", ->
    expectToNotSee header "Pre-loaded window"
    click button "Show pre-loaded window"
    expectToSee header "Pre-loaded window"
