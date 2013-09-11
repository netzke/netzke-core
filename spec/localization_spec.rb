require 'spec_helper'

feature "Localization", js: true do
  it "runs successfully for Spanish version of Localization" do
    run_mocha_spec 'localization_en', component: Localization, locale: "en"
    run_mocha_spec 'localization_en', component: LocalizationExtended, locale: "en"

    run_mocha_spec 'localization_es', component: Localization, locale: "es"
    run_mocha_spec 'localization_es', component: LocalizationExtended, locale: "es"
  end
end
