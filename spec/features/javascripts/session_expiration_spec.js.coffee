describe 'SessionExpiration component', ->
  it 'informs user that the session has expired', ->
    click button 'Destroy session'
    wait().then ->
      click button 'With response'
      wait()
    .then ->
      expectToSee header 'Session expired'
