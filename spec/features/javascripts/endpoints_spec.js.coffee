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

  it "issues callback in component's scope by default", (done) ->
    click button 'Callback'
    wait ->
      expect(currentPanelTitle()).to.eql('Callback invoked')
      done()

  it "issues callback in specified scope", (done) ->
    click button 'Callback and scope'

    wait ->
      expectToSee header 'Fancy title set!'
      done()

  it "calls endpoint that returns a value to callback function", (done) ->
    click button 'Return value'

    wait ->
      expect(currentPanelTitle()).to.eql('Returned value: 42, success: true')
      done()

  it "gets informed about calling endpoint on non-existing child", (done) ->
    click button 'Non existing'

    wait ->
      expect(currentPanelTitle()).to.eql("Error: UNKNOWN_COMPONENT, message: Component 'Endpoints' does not have component 'non_existing_child'")
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

  # Client-side test passes, but server exception makes RSpec conclude it's a failure; needs a work-around
  xit "informs about exception", (done) ->
    click button 'Raise exception'
    wait ->
      expect(currentPanelTitle()).to.eql('Response status: 500, success: false')
      done()
