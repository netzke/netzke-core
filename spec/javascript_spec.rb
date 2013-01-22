require 'spec_helper'

feature "JavaScript specs", js: true do
  %w[Endpoints DynamicLoading Composition Localization].each do |component|
    it "should successfully run for #{component}" do
      run_js_specs_for(component)
    end
  end

  it "should successfully run Spanish version of Localization" do
    run_js_specs_for("Localization", :es)
    restore_locale
  end
end
