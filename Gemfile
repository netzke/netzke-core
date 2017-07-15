source 'http://rubygems.org'

gemspec

gem 'rails', '~>5.1.0'
gem 'sqlite3'
gem 'yard'
gem 'rake'

group :test do
  gem 'rspec'
  gem 'rspec-rails', '~> 3.5.0'
  gem 'capybara'
  gem 'capybara-selenium'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
end

group :development do
  gem 'web-console'
end

group :development, :test do
  gem 'pry-rails'
  gem 'netzke-testing', github: 'thepry/netzke-testing', branch: 'ext-6-rails-5'
end
