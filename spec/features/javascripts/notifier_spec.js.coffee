describe "Notifier component", ->
  it "fires various notifications", (done) ->
    click button "Notify"
    expectToSee somewhere "Local feedback"
    expectToSee somewhere "Local notification"

    click button "Multiple notify"
    expectToSee somewhere "Line one"
    expectToSee somewhere "Line two"

    click button "Server notify"
    wait ->
      expectToSee somewhere "Message from server"
      expectToSee somewhere "Server notification"
      done()
