describe "Routing::TopLevel component", ->
  it "loads nested component via routing", (done) ->
    click button "Load one one"
    wait().then ->
      expectToSee header "TopLevel"
      expectToSee header "One"
      expectToSee header "OneOne"
      click button "Load one two"
      wait()
    .then ->
      expectToSee header "TopLevel"
      expectToSee header "One"
      expectToSee header "OneTwo"
      done()
