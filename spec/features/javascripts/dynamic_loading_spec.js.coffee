describe 'DynamicLoading component', ->
  it "should load component", (done) ->
    click button('Load component')
    wait ->
      expect(header('SimpleComponent')).to.be.ok()
      done()

  it "should load component repeatively", (done) ->
    click button('Load component')
    wait ->
      done()

  it "should load component in a window", (done) ->
    click button('Load in window')
    wait ->
      expect(header('Component loaded in window')).to.be.ok()
      closeWindow()
      done()

  it "should invoke a callback on loading a component", (done) ->
    click button('Load with feedback')
    wait ->
      expect(header('Callback invoked!')).to.be.ok()
      done()

  it "should load a window component nesting another component", (done) ->
    click button('Load window with simple component')
    wait ->
      expect(header('Simple Component Inside Window')).to.be.ok()
      closeWindow()
      done()

  it "should load a component with params", (done) ->
    click button('Load with params')
    wait ->
      expect(header('Simple Component with modified title')).to.be.ok()
      done()

  it "should gracefully fail loading a non-existing component", (done) ->
    click button('Non-existing component')
    wait ->
      expectToSee somewhere "Couldn't load component 'non_existing_component'"
      expectToNotSee anywhere "Loading..."
      done()

  it "should not be able to load an excluded component", (done) ->
    click button('Inaccessible')
    wait ->
      expectToSee somewhere "Couldn't load component 'inaccessible'"
      done()

  it "should be able to load component's config", (done) ->
    click button 'Config only'
    wait ->
      expect(header('SimpleComponent (overridden)')).to.be.ok()
      done()

  it "should be able to load a functional auto-reloading component", (done) ->
    click button('Load self reloading')
    wait ->
      expect(header('Loaded 1 time(s)')).to.be.ok()
      click button 'Reload'
      wait ->
        expect(header('Loaded 2 time(s)')).to.be.ok()
        done()

  it 'loads components with its class specified by client side', (done) ->
    click button 'Load dynamic child'
    wait().then ->
      expectToSee header 'Endpoints'
      click button 'With response'
      wait()
    .then ->
      expectToSee header 'Hello world'
      done()
