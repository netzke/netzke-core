begin
  require 'jeweler'
  require './lib/netzke/core/version'
  Jeweler::Tasks.new do |gemspec|
    gemspec.version = Netzke::Core::Version::STRING
    gemspec.name = "netzke-core"
    gemspec.summary = "Client-server GUI components with Sencha Ext JS and Ruby"
    gemspec.description = "Allows building complex RIA by greatly facilitating modular development"
    gemspec.email = "nmcoder@gmail.com"
    gemspec.homepage = "http://netzke.org"
    gemspec.authors = ["nomadcoder"]
    gemspec.add_dependency("activesupport", ">=3.1.0")
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

begin
  require 'yard'

  YARD::Rake::YardocTask.new do |t|
    t.options = ['--title', "Netzke Core #{Netzke::Core::Version::STRING}"]
  end

  namespace :yard do
    desc "Publish docs to api.netzke.org"
    task publish: :yard do
      dir = 'www/api.netzke.org/core'
      puts "Publishing to fl:#{dir}..."
      `ssh fl "mkdir -p #{dir}"`
      `scp -r doc/* fl:#{dir}`
    end
  end
rescue
  puts "To enable yard do 'gem install yard'"
end
