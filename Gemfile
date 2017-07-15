source 'http://rubygems.org'

gemspec

gem 'rails', '~>4.2.0'
gem 'sqlite3'
gem 'yard'
gem 'rake'

group :test do
  gem 'rspec'
  gem 'rspec-rails'
  gem 'capybara'
  gem 'capybara-selenium'
  gem 'selenium-webdriver'
end

group :development do
  gem 'web-console', '~> 2.0'
end

group :development, :test do
  gem 'pry-rails'
  gem 'netzke-testing', github: 'netzke/netzke-testing', branch: 'master'
end
