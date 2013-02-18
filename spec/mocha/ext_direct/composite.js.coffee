describe "ExtDirect::Composite component", ->
  it 'should trigger update on 2 child components issuing 1 actual server request', (done) ->
   Ext.ComponentQuery.query('textfield[name="user"]')[0].setValue "nomadcoder"
   click button "Update"
   wait ->
     expectToSee header 'Details for user nomadcoder'
     expectToSee header 'Statistics for user nomadcoder'
     expect(Netzke.connectionCount).to.equal 1
     done()
