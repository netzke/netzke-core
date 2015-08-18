describe "BufferedRequest component", ->
  it "should buffer 2 endpoint calls into a single AJAX request", (done) ->
    click button "Buffered call"
    setTimeout ->
      expect(Netzke._pendingRequests ).to.eql(1)
      done()
    , 10
