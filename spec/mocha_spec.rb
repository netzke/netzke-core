require 'spec_helper'

feature "Mocha specs", js: true do
  # create a spec for each file in mocha/**/* except for extra/ and support/
  dir = File.join(File.dirname(__FILE__), "mocha")
  Dir[File.join(dir, "**/*")].each do |f|
    next if File.directory?(f)

    file = f.gsub(dir, "")[1..-1].split(".").first
    next if file.index(/helper$/) || file.index(/^extra\//)

    spec = file.gsub("/", "__")
    comp = file.split("/").map(&:camelize).join("::")

    it "runs successfully for #{comp}" do
      run_js_specs(comp, spec)
    end
  end

  it "runs successfully for Spanish version of Localization" do
    run_js_specs("Localization", "extra__localization_es", :es)
    restore_locale
  end
end
