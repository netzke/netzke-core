Netzke::Core.setup do |config|
  config.js_direct_max_retries = 2
  config.ext_uri = "http://cdn.sencha.com/ext-4.1.1a-gpl" if ENV['EXTJS_SRC'] == 'cdn'

  # feedback delay
  # config.js_feedback_delay = 2000
end

ConfigurableOnClassLevel.title = "Overridden"
