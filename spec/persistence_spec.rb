require 'spec_helper'

feature "Persistence", js: true do
  it "should store persistent settings over a page reload" do
    visit "/components/Persistence?spec=extra__persistence_set"
    wait_for_javascript
    assert_mocha_results

    visit "/components/Persistence?spec=extra__persistence_reset"
    wait_for_javascript
    assert_mocha_results

    visit "/components/Persistence?spec=extra__persistence_set"
    wait_for_javascript
    assert_mocha_results

    visit "/components/PersistenceWithSharedState?spec=extra__persistence_reset"
    wait_for_javascript
    assert_mocha_results
  end

  it "should store a session variable, but not over the page reload" do
    run_js_specs("Persistence", "extra__persistence_session")

    # it's good enough to simply re-run the spec in order to insure that component session is reset on page reload
    run_js_specs("Persistence", "extra__persistence_session")
  end
end
