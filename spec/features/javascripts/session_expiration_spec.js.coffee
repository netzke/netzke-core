describe 'SessionExpiration component', ->
  it 'informs user that the session has expired', (done) ->
    click button 'Destroy session'
    wait ->
      click button 'With response'
      wait ->
        expectToSee header 'Session expired'
        done()
