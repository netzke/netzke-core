require "./lib/netzke/core/version"

Gem::Specification.new do |s|
  s.name        = "netzke-core"
  s.version     = Netzke::Core::VERSION
  s.author      = "Max Gorin"
  s.email       = "gorinme@gmail.com"
  s.homepage    = "http://netzke.org"
  s.summary     = "Client-server GUI components with Sencha Ext JS and Ruby on Rails"
  s.description = "Build complex backend apps in a modular way"

  s.files         = Dir["{app,javascripts,lib,stylesheets,tasks}/**/*", "[A-Z]*", "init.rb"] - ["Gemfile.lock"]
  s.test_files    = Dir["{test}/**/*"]
  s.require_paths = ["lib"]

  s.add_dependency 'uglifier'
  s.add_dependency 'execjs'

  s.add_development_dependency 'rails', '~> 4.0.0'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'redcarpet'
  s.add_development_dependency 'yard'
  s.add_development_dependency 'coffee-script'
  s.add_development_dependency 'pry-rails'

  s.add_development_dependency 'netzke-testing', '0.10.0.rc1'

  s.required_rubygems_version = ">= 1.3.4"
end
