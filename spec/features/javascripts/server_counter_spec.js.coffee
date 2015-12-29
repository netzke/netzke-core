describe 'ServerCounter component', ->
  it "multiplexes quick consequent endpoint calls", (done) ->
    click button 'Count seven times'
    wait ->
      expect(Netzke.connectionCount).to.equal 1
      expectToSee header 'I am at 7'
      done()

  it "preserves endpoint calling order", (done) ->
    click button 'Do ordered'
    wait ->
      expectToSee header 'Second. 2'
      done()

  it "uses retry mechanism to recover from failed endpoint calls", (done) ->
    click button 'Fail two out of five'
    wait ->
      expectToSee header '0 1 2 3 4 5'
      done()
