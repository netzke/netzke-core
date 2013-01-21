describe "Composition component", ->
  it "should have 4 nested components", ->
    expectToSee headerWithTitle "Endpoints"
    expectToSee headerWithTitle "Extended Endpoints"
    expectToSee headerWithTitle "A panel"
    expectToSee headerWithTitle "Another panel"

  it "should have properly working nested components", (done) ->
    clickButton "With response"
    wait ->
      expectToSee headerWithTitle "All quiet here on the server"
      clickButton "With extended response"
      wait ->
        expectToSee headerWithTitle "All quiet here on the server indeed"
        done()

  it "as server, should be able to address (deeply) nested components", (done) ->
    clickButton "Update west from server"
    wait ->
      expectToSee headerWithTitle "Here's an update for west panel"
      clickButton "Update east south from server"
      wait ->
        expectToSee headerWithTitle "Here's an update for south panel in east panel"
        done()

  it "should instantiate a pre-loaded component", ->
    expectNotToSee headerWithTitle "Pre-loaded window"
    clickButton "Show pre-loaded window"
    expectToSee headerWithTitle "Pre-loaded window"
