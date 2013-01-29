require 'spec_helper'

feature "JavaScript specs", js: true do
  # create a spec for each file in javascripts/**/* except for extra/ and support/
  dir = File.join(File.dirname(__FILE__), "javascripts")
  Dir[File.join(dir, "**/*")].each do |f|
    next if File.directory?(f)

    file = f.gsub(dir, "")[1..-1].split(".").first
    next if file.index(/helper$/) || file.index(/^extra\//)

    spec = file.gsub("/", "__")
    comp = file.split("/").map(&:camelize).join("::")

    it "should successfully run for #{comp}" do
      run_js_specs(comp, spec)
    end
  end

  it "should successfully run for Spanish version of Localization" do
    run_js_specs("Localization", "extra__localization_es", :es)
    restore_locale
  end
end
