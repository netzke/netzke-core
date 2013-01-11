require "./lib/netzke/core/version"

Gem::Specification.new do |s|
  s.name        = "netzke-core"
  s.version     = Netzke::Core::Version::STRING
  s.author      = "nomadcoder"
  s.email       = "nmcoder@gmail.com"
  s.homepage    = "http://netzke.org"
  s.summary     = "Client-server GUI components with Sencha Ext JS and Ruby"
  s.description = "Allows building complex RIA by greatly facilitating modular development"

  s.files         = Dir["{app,javascripts,lib,stylesheets,tasks}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.test_files    = Dir["{test}/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency 'uglifier'
  s.add_dependency 'execjs'

  s.add_development_dependency 'capybara', '~> 1'
  s.add_development_dependency 'cucumber-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'rails', '3.2.10'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'yard'

  s.required_rubygems_version = ">= 1.3.4"
end
