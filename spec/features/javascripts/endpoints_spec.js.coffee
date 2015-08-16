describe 'Endpoints component', ->
  it "calls an endpoint", (done) ->
    click button 'With response'

    wait ->
      expectToSee header 'Hello world'
      done()

  it "calls an endpoint without response", (done) ->
    click button 'No response'

    wait ->
      expect(currentPanelTitle()).to.eql('Successfully called endpoint with no response (this is a callback)')
      done()

  it "calls an endpoint that calls back with multiple arguments", (done) ->
    click button 'Multiple argument response'

    wait ->
      expect(currentPanelTitle()).to.eql('Called a function with two arguments: First argument, Second argument')
      done()

  it "calls an endpoint that calls back with an array as an argument", (done) ->
    click button 'Array as argument'

    wait ->
      expect(currentPanelTitle()).to.eql("Called a function with array as arguments: ['Element 1', 'Element 2']")
      done()

  it "calls an endpoint with callback and scope", (done) ->
    click button 'Callback and scope'

    wait ->
      expectToSee header 'Fancy title set!'
      done()

  it "calls endpoint that returns a value to callback function", (done) ->
    click button 'Return value'

    wait ->
      expect(currentPanelTitle()).to.eql('Returned value: 42')
      done()

  it "gets informed about calling endpoint on non-existing child", (done) ->
    click button 'Non existing'

    wait ->
      expectToSee somewhere "Unknown component 'non_existing_child' in 'endpoints'"
      done()

  it "calls an endpoint with multiple argmuments", (done) ->
    click button 'Multiple arguments'
    wait ->
      expect(currentPanelTitle()).to.eql('Returned value: one, two, three')
      done()

  it "calls an endpoint with a hash argument", (done) ->
    click button 'Hash argument'
    wait ->
      expect(currentPanelTitle()).to.eql('Returned value: one, two')
      done()

  it "issues a batch call", (done) ->
    click button 'Batched call'
    wait ->
      expect(currentPanelTitle()).to.eql('foo bar')
      done()
