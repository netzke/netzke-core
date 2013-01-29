require 'spec_helper'

feature "JavaScript specs", js: true do
  tested_components = %w[
    Actions
    Tools
    Endpoints
    DynamicLoading
    Composition
    Localization
    LocalizationExtended
    Scoped::Scoping
    Scoped::ScopingExtended
    Scoped::DeeplyScoped::Scoping
    RequireCss
    LoadedRequireCss
  ]

  tested_components.each do |component|
    it "should successfully run for #{component}" do
      run_js_specs_for(component)
    end
  end

  it "should successfully run for Spanish version of Localization" do
    run_js_specs_for("Localization", :es)
    restore_locale
  end
end
