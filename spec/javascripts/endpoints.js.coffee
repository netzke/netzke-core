describe 'Endpoints component', ->
  it "should call an endpoint", (done) ->
    click button 'With response'

    wait ->
      expectToSee header 'Response from server'
      done()

  it "should call an endpoint without response", (done) ->
    click button 'No response'

    wait ->
      expect(currentPanelTitle()).to.eql('Successfully called endpoint with no response (this is a callback)')
      done()

  it "should call an endpoint that calls back with multiple arguments", (done) ->
    click button 'Multiple arguments'

    wait ->
      expect(currentPanelTitle()).to.eql('Called a function with two arguments: First argument, Second argument')
      done()

  it "should call an endpoint that calls back with an array as an argument", (done) ->
    click button 'Array as argument'

    wait ->
      expect(currentPanelTitle()).to.eql("Called a function with array as arguments: ['Element 1', 'Element 2']")
      done()

  it "should call an endpoint with callback and scope", (done) ->
    click button 'Callback and scope'

    wait ->
      expectToSee header 'Fancy title set!'
      done()

  it "should call endpoint that returns a value to callback function", (done) ->
    click button 'Return value'

    wait ->
      expect(currentPanelTitle()).to.eql('Returned value: 42')
      done()
