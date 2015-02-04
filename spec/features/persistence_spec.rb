require 'spec_helper'

feature "Persistence", js: true do
  it "should store persistent settings over a page reload" do
    run_mocha_spec 'persistence_set', component: Persistence
    run_mocha_spec 'persistence_reset', component: Persistence
    run_mocha_spec 'persistence_set', component: Persistence
    run_mocha_spec 'persistence_reset', component: PersistenceWithSharedState
  end

  it "should store a session variable, but not over the page reload" do
    run_mocha_spec 'persistence_session', component: Persistence
    # it's good enough to simply re-run the spec in order to ensure that component session is reset on page reload
    run_mocha_spec 'persistence_session', component: Persistence
  end
end
