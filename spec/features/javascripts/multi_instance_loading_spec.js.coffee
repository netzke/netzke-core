describe 'MultiInstanceLoading component', ->
  it 'loads multiple child components with different parameters', ->
    click button 'Load hello user'
    wait().then ->
      expectToSee tab 'Configured with user User 1'
      click button 'Ping server'
      wait()
    .then ->
      expectToSee header 'Server says: Hello User 1!'
      click button 'Load hello user'
      wait()
    .then ->
      expectToSee tab 'Configured with user User 2'
      click tab 'Configured with user User 2'
      click button 'Ping server'
      wait()
    .then ->
      expectToSee header 'Server says: Hello User 2!'

  it 'loads an instance of child component in precreated tab', ->
    click button 'Load hello user in precreated tab'
    wait().then ->
      expectToSee tab 'Tab 3'
      click button 'Ping server'
      wait()
    .then ->
      expectToSee header 'Server says: Hello User 3!'

  it 'loads composite child component', ->
    click button 'Load composition'
    wait().then ->
      expectToSee header 'Endpoints Extended'
      click button 'With extended response'
      wait()
    .then ->
      expectToSee header 'Hello world plus'

      # and once more
      click button 'Load composition'
      wait()
    .then ->
      expectToSee header 'Endpoints Extended'
      click button 'With extended response'
      wait()
    .then ->
      expectToSee header 'Hello world plus'

  it 'loads child component config', ->
    click button 'Load config only'
    wait().then ->
      expectToSee header 'Loaded itemId: custom_item_id'
