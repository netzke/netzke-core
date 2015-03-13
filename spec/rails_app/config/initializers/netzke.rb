Netzke::Core.setup do |config|
  config.ext_uri = "http://cdn.sencha.com/ext/gpl/5.1.0" if ENV['EXTJS_SRC'] == 'cdn'

  # custom session expiration handling
  config.ext_javascripts << "#{File.dirname(__FILE__)}/javascripts/session_expiration.js"

  # feedback delay
  # config.js_feedback_delay = 2000
end

ConfigurableOnClassLevel.title = "Overridden"

Netzke::Testing.setup do |config|
  config.spec_root = File.expand_path("../../../../..", __FILE__)
end
