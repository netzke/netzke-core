describe 'DynamicLoading component', ->
  it "should load component", (done) ->
    clickButton('Load component')
    wait ->
      expect(headerWithTitle('SimpleComponent')).to.be.ok()
      done()

  it "should load component in a window", (done) ->
    clickButton('Load in window')
    wait ->
      expect(headerWithTitle('Component loaded in window')).to.be.ok()
      closeWindow()
      done()

  it "should invoke a callback on loading a component", (done) ->
    clickButton('Load with feedback')
    wait ->
      expect(headerWithTitle('Callback invoked!')).to.be.ok()
      done()

  it "should load a window component nesting another component", (done) ->
    clickButton('Load window with simple component')
    wait ->
      expect(headerWithTitle('Simple Component Inside Window')).to.be.ok()
      closeWindow()
      done()

  it "should load a component with params", (done) ->
    clickButton('Load with params')
    wait ->
      expect(headerWithTitle('Simple Component with modified title')).to.be.ok()
      done()

  it "should gracefully fail loading a non-existing component", (done) ->
    clickButton('Non-existing component')
    wait ->
      expectToSee somewhere "Couldn't load component 'non_existing_component'"
      expectToNotSee anywhere "Loading..."
      done()

  it "should not be able to load an excluded component", (done) ->
    clickButton('Inaccessible')
    wait ->
      expectToSee somewhere "Couldn't load component 'inaccessible'"
      done()

  it "should be able to load component's config", (done) ->
    clickButton 'Config only'
    wait ->
      expect(headerWithTitle('SimpleComponent (overridden)')).to.be.ok()
      done()

  it "should be able to load a functional auto-reloading component", (done) ->
    clickButton('Load self reloading')
    wait ->
      expect(headerWithTitle('Loaded 1 time(s)')).to.be.ok()
      clickButton('Reload')
      wait ->
        expect(headerWithTitle('Loaded 2 time(s)')).to.be.ok()
        done()
