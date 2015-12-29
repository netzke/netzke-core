describe "ExtDirect::Composite component", ->
  it 'triggers update on 2 child components issuing 1 actual server request', (done) ->
   Ext.ComponentQuery.query('textfield[name="user"]')[0].setValue "mxgrn"
   click button "Update"
   wait ->
     expectToSee header 'Details for user mxgrn'
     expectToSee header 'Statistics for user mxgrn'
     expect(Netzke.connectionCount).to.equal 1
     done()
