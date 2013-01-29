module Helpers
  def run_js_specs(component, spec, lang = nil)
    # spec = component.gsub("::", "__").underscore
    # spec << "_#{lang}" if lang

    url = "/components/#{component}?spec=#{spec}"
    url << "&locale=#{lang}" if lang

    visit url

    # Wait while the test is running
    start = Time.now
    loop do
      done = page.execute_script(<<-JS)
      return Netzke.mochaDone;
      JS

      done ? break : sleep(0.1)

      raise "Timeout running JavaScript specs for #{component}" if Time.now > start + 10.seconds # no specs are supposed to run longer than this
    end

    result = page.execute_script(<<-JS)
      var stats = Netzke.mochaRunner.stats;
      return stats.failures == 0 && stats.tests !=0
    JS

    raise "Spec faild at url: #{url}" if !result
  end

  def restore_locale
    visit "/components/Localization?locale=en"
  end
end
