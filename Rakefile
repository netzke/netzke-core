begin
  require 'jeweler'
  require './lib/netzke/core/version'
  Jeweler::Tasks.new do |gemspec|
    gemspec.version = Netzke::Core::Version::STRING
    gemspec.name = "netzke-core"
    gemspec.summary = "Build ExtJS/Rails components with minimum effort"
    gemspec.description = "Allows building ExtJS/Rails reusable code in a DRY way"
    gemspec.email = "sergei@playcode.nl"
    gemspec.homepage = "http://github.com/skozlov/netzke-core"
    gemspec.rubyforge_project = "netzke-core"
    gemspec.authors = ["Sergei Kozlov"]
    gemspec.add_dependency("activesupport", ">=3.0.1")
    gemspec.post_install_message = <<-MESSAGE

========================================================================

           Thanks for installing Netzke Core!
           
  Netzke home page:     http://netzke.org
  Netzke Google Groups: http://groups.google.com/group/netzke
  Netzke tutorials:     http://blog.writelesscode.com

========================================================================

MESSAGE
    
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "netzke-core #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end
