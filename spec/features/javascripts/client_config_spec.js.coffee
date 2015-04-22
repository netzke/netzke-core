describe 'ClientConfig component', ->
  it "should pass client config to server side", (done) ->
    click button "Show option one"
    wait()
    .then ->
      expectToSee header "One"
      click button "Show option two"
      wait()
    .then ->
      expectToSee header "Two"
      done()
