module Helpers
  def run_js_specs(component, spec, lang = nil)
    url = "/components/#{component}?spec=#{spec}"
    url << "&locale=#{lang}" if lang

    visit url

    # Wait while the test is running
    wait_for_javascript

    assert_mocha_results
  end

  def wait_for_javascript
    start = Time.now
    loop do
      done = page.execute_script(<<-JS)
      return Netzke.mochaDone;
      JS

      done ? break : sleep(0.1)

      raise "Timeout running JavaScript specs for #{component}" if Time.now > start + 10.seconds # no specs are supposed to run longer than this
    end
  end

  def restore_locale
    visit "/components/Localization?locale=en"
  end

  def assert_mocha_results
    result = page.execute_script(<<-JS)
      var stats = Netzke.mochaRunner.stats;
      return stats.failures == 0 && stats.tests !=0
    JS

    raise "JS spec faild" if !result
  end
end
