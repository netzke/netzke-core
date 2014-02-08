require "bundler/gem_tasks"
require 'yard'

# Load tasks, that will be available for Rails user
Dir[File.join(File.dirname(__FILE__), './lib/tasks/*.rake')].each { |file| load file }

# Load tasks for gem development
Dir[File.join(File.dirname(__FILE__), 'tasks/*.rake')].each { |file| load file }

YARD::Rake::YardocTask.new do |t|
  t.options = ['--title', "Netzke Core #{Netzke::Core::VERSION}"]
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

desc 'rake test'
task default: :test
