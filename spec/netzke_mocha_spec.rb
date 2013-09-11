require 'spec_helper'

feature "Mocha specs", js: true do
  # if a spec path is provided, create a single spec for it
  if path = ENV["S"]
    it "pass for '#{path}'" do
      run_mocha_spec(path)
    end
  else
    # create a spec for each file spec dir that ends on "_spec.js.coffee"
    dir = File.join File.dirname(__FILE__), "javascripts"
    Dir[File.join(dir, "**/*_spec.js.coffee")].each do |f|
      spec_path = f.sub(dir, '')[1..-1].sub(/_spec\..*$/, '')

      it "pass for '#{spec_path.underscore}_spec.js.coffee'" do
        run_mocha_spec spec_path
      end
    end
  end
end
