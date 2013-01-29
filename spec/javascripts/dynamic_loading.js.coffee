describe 'DynamicLoading component', ->
  it "should load component", (done) ->
    click buttonWithText('Load component')
    wait ->
      expect(headerWithTitle('SimpleComponent')).to.be.ok()
      done()

  it "should load component in a window", (done) ->
    click buttonWithText('Load in window')
    wait ->
      expect(headerWithTitle('Component loaded in window')).to.be.ok()
      closeWindow()
      done()

  it "should invoke a callback on loading a component", (done) ->
    click buttonWithText('Load with feedback')
    wait ->
      expect(headerWithTitle('Callback invoked!')).to.be.ok()
      done()

  it "should load a window component nesting another component", (done) ->
    click buttonWithText('Load window with simple component')
    wait ->
      expect(headerWithTitle('Simple Component Inside Window')).to.be.ok()
      closeWindow()
      done()

  it "should load a component with params", (done) ->
    click buttonWithText('Load with params')
    wait ->
      expect(headerWithTitle('Simple Component with modified title')).to.be.ok()
      done()

  it "should gracefully fail loading a non-existing component", (done) ->
    click buttonWithText('Non-existing component')
    wait ->
      expectToSee somewhere "Couldn't load component 'non_existing_component'"
      expectToNotSee anywhere "Loading..."
      done()

  it "should not be able to load an excluded component", (done) ->
    click buttonWithText('Inaccessible')
    wait ->
      expectToSee somewhere "Couldn't load component 'inaccessible'"
      done()

  it "should be able to load component's config", (done) ->
    click buttonWithText 'Config only'
    wait ->
      expect(headerWithTitle('SimpleComponent (overridden)')).to.be.ok()
      done()

  it "should be able to load a functional auto-reloading component", (done) ->
    click buttonWithText('Load self reloading')
    wait ->
      expect(headerWithTitle('Loaded 1 time(s)')).to.be.ok()
      click buttonWithText('Reload')
      wait ->
        expect(headerWithTitle('Loaded 2 time(s)')).to.be.ok()
        done()
