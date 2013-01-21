module Helpers
  def run_js_specs_for(component)
    visit "/components/#{component}?spec=#{component.underscore}"

    start = Time.now
    loop do
      done = page.execute_script(<<-JS)
      return Netzke.mochaDone;
      JS

      done ? break : sleep(0.1)

      raise "Timeout running JavaScript specs for #{component}" if Time.now > start + 10.seconds # no specs are supposed to run longer than this
    end

    # Make wait while the test is running
    page.execute_script(<<-JS).should == 0
    var runner = Netzke.mochaRunner;
    return runner.failures;
    JS
  end
end
