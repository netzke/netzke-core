Netzke::Core.setup do |config|
  config.js_direct_max_retries = 2
  config.ext_uri = "http://cdn.sencha.com/ext-4.1.1a-gpl" if ENV['EXTJS_SRC'] == 'cdn'
end

ConfigurableOnClassLevel.title = "Overridden"
