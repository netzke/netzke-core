describe 'PersistentLoading component', ->
  it 'loads multiple child components with different parameters', (done) ->
    click button 'Persistent tab'
    wait ->
      expectToSee tab 'Configured with user User 1'
      click button 'Persistent tab'
      wait ->
        expectToSee tab 'Configured with user User 2'
        done()
