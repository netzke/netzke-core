describe "Tools component", ->
  it "should handle clicking a tool", ->
    click tool 'gear'
    expectToSee headerWithTitle "Gear tool clicked"

    click tool 'refresh'
    expectToSee headerWithTitle "Refresh tool clicked"
