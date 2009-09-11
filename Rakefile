begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "netzke-core"
    gemspec.summary = "Build ExtJS/Rails widgets with minimum effort"
    gemspec.description = "Build ExtJS/Rails widgets with minimum effort"
    gemspec.email = "sergei@playcode.nl"
    gemspec.homepage = "http://github.com/skozlov/netzke-core"
    gemspec.rubyforge_project = "netzke-core"
    gemspec.authors = ["Sergei Kozlov"]
  end
  Jeweler::RubyforgeTasks.new do |rubyforge|
    rubyforge.doc_task = "rdoc"
  end
    
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
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
