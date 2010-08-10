require 'netzke-core'
begin
  require 'jsmin'
rescue 
  message=%q(WARNING: netzke-core requires the JSMin gem. You either don't have the gem installed,
  or you haven't told Rails to require it. If you're using a recent version of Rails:
  config.gem "jsmin" # in config/environment.rb
  and of course install the gem: sudo gem install jsmin)
  puts message
  Rails.logger.error message
end

