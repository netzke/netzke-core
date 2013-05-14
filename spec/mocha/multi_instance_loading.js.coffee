describe 'MultiInstanceLoading component', ->
  it 'loads multiple child components with different parameters', (done) ->
    click button 'Load hello user'
    wait ->
      expectToSee tab 'Configured with user User 1'
      click button 'Load hello user'
      wait ->
        expectToSee tab 'Configured with user User 2'
        done()

  it 'loads composite child component', (done) ->
    click button 'Load composition'
    wait ->
      expectToSee header 'Endpoints Extended'
      click button 'With extended response'
      wait ->
        expectToSee header 'Response from server plus'

        # and once more
        click button 'Load composition'
        wait ->
          expectToSee header 'Endpoints Extended'
          click button 'With extended response'
          wait ->
            expectToSee header 'Response from server plus'
            done()
