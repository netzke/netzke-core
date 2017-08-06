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
  gem 'selenium-webdriver', '~> 3.4.4'
  gem 'chromedriver-helper'
end

group :development do
  gem 'web-console', '~> 2.0'
end

group :development, :test do
  gem 'pry-rails'
  gem 'netzke-testing', git: 'https://github.com/netzke/netzke-testing', branch: '6-5-0'
end
