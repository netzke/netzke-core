describe 'ClientConfig component', ->
  it "should pass client config to server side", (done) ->
    click button "Show option one"
    wait ->
      expectToSee header "One"
      click button "Show option two"
      wait ->
        expectToSee header "Two"
        done()
