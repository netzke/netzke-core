require 'spec_helper'

feature "JavaScript specs", js: true do
  %w[Endpoints DynamicLoading Composition].each do |component|
    it "should successfully run for #{component}" do
      run_js_specs_for(component)
    end
  end
end
