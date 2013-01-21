describe 'Endpoints component', ->
  it "should call an endpoint", (done) ->
    clickButton('With response')

    wait ->
      expect(currentPanelTitle()).to.eql('All quiet here on the server')
      done()

  it "should call an endpoint without response", (done) ->
    clickButton('No response')

    wait ->
      expect(currentPanelTitle()).to.eql('Successfully called endpoint with no response (this is a callback)')
      done()

  it "should call an endpoint that calls back with multiple arguments", (done) ->
    clickButton('Multiple arguments')

    wait ->
      expect(currentPanelTitle()).to.eql('Called a function with two arguments: First argument, Second argument')
      done()

  it "should call an endpoint that calls back with an array as an argument", (done) ->
    clickButton('Array as argument')

    wait ->
      expect(currentPanelTitle()).to.eql("Called a function with array as arguments: ['Element 1', 'Element 2']")
      done()

  it "should call an endpoint with callback and scope", (done) ->
    clickButton('Callback and scope')

    wait ->
      expect(currentPanelTitle()).to.eql('Fancy title set!')
      done()

  it "should call endpoint that returns a value to callback function", (done) ->
    clickButton 'Return value'

    wait ->
      expect(currentPanelTitle()).to.eql('Returned value: 42')
      done()
