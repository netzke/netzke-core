describe 'Endpoints component', ->
  it "should call an endpoint", (done) ->
    click buttonWithText 'With response'

    wait ->
      expectToSee headerWithTitle 'All quiet here on the server'
      done()

  it "should call an endpoint without response", (done) ->
    click buttonWithText 'No response'

    wait ->
      expect(currentPanelTitle()).to.eql('Successfully called endpoint with no response (this is a callback)')
      done()

  it "should call an endpoint that calls back with multiple arguments", (done) ->
    click buttonWithText 'Multiple arguments'

    wait ->
      expect(currentPanelTitle()).to.eql('Called a function with two arguments: First argument, Second argument')
      done()

  it "should call an endpoint that calls back with an array as an argument", (done) ->
    click buttonWithText 'Array as argument'

    wait ->
      expect(currentPanelTitle()).to.eql("Called a function with array as arguments: ['Element 1', 'Element 2']")
      done()

  it "should call an endpoint with callback and scope", (done) ->
    click buttonWithText 'Callback and scope'

    wait ->
      expectToSee headerWithTitle 'Fancy title set!'
      done()

  it "should call endpoint that returns a value to callback function", (done) ->
    click buttonWithText 'Return value'

    wait ->
      expect(currentPanelTitle()).to.eql('Returned value: 42')
      done()
