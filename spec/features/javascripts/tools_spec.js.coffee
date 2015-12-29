describe "Tools component", ->
  it "handles clicking a tool", ->
    click tool 'gear'
    expectToSee header "Gear tool clicked"

    click tool 'refresh'
    expectToSee header "Refresh tool clicked"
