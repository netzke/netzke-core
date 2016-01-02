describe "Composition component", ->
  it "has 4 nested components", ->
    expectToSee header "Endpoints"
    expectToSee header "Endpoints Extended"
    expectToSee header "A panel"
    expectToSee header "Another panel"

  it "does not show excluded component", ->
    expectToNotSee header "Should not be seen"

  it "has properly working nested components", ->
    click button "With response"
    wait().then ->
      expectToSee header "Hello world"
      click button "With extended response"
      wait()
    .then ->
      expectToSee header "Hello world plus"

  it "as server, addresses (deeply) nested components", ->
    click button "Update west from server"
    wait().then ->
      expectToSee header "Here's an update for west panel"
      click button "Update east south from server"
      wait()
    .then ->
      expectToSee header "Here's an update for south panel in east panel"

  it "instantiates a pre-loaded component", ->
    expectToNotSee header "Pre-loaded window"
    click button "Show pre-loaded window"
    expectToSee header "Pre-loaded window"
