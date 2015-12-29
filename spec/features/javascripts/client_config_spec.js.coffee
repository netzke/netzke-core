describe 'ClientConfig component', ->
  it "passes client config to server side", (done) ->
    click button "Show option one"
    wait()
    .then ->
      expectToSee header "One"
      expectToSee header "Server says: Hello One Left!"
      expectToSee header "Server says: Hello One Right!"
      click button "Show option two"
      wait()
    .then ->
      expectToSee header "Two"
      expectToSee header "Server says: Hello Two Left!"
      expectToSee header "Server says: Hello Two Right!"
      done()
