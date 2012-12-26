#
#  Task for test performing :
#
#      test         - run tests on test rails application, it will run `rspec spec` and
#                     `cucumber features` on application from test/core_test_app folder.
#
#      test:prepare - prepare test application for testing, creates symbolic link to
#                     database.yml from database.sample.yml and run db:create, db:migrate
#                     and db:seed rake tasks. Also it allows to install Extjs library for
#                     the test app, to do it you will need to specify --with-extjs parameter.
#
#      test:check   - run to check if test app is ready for testing.
#

require './tasks/rake_helper'

def download_extjs(options = {})
  return false unless (extjs_home = options[:to])
  extjs_download_url = "http://cdn.sencha.io/ext-4.1.1a-gpl.zip"
  archive_name       = extjs_download_url.match(/[^\/]+$/)[0]
  extracted_folder   = archive_name.match(/^(.+)-gpl\.[^\.]+$/)[1]
  system(%(wget #{extjs_download_url}))                 ||
  system(%(mkdir -p #{extjs_home}))                     ||
  system(%(unzip #{archive_name}"))                     ||
  system(%(mv "#{extracted_folder}/*" #{extjs_home}))   ||
  system(%(rm "#{extracted_folder}" "#{archive_name}"))
end

def install_extjs
  extjs_home = File.join(GemInfo.gem_root, 'extjs')
  return false unless download_extjs(to: extjs_home)
  system %(ln -s #{extjs_home} #{File.join(GemInfo.test_app_root, 'public', 'extjs')})
end

task :test do
  system %(cd #{GemInfo.test_app_root} && bundle exec rspec spec)
  system %(cd #{GemInfo.test_app_root} && bundle exec cucumber features)
end

namespace :test do

  desc "Checks if test application is ready for testing."
  task :check do
    puts "Checking application in #{GemInfo.test_app_root} folder."
    if !File.exists?(File.join(GemInfo.test_app_root, 'public', 'extjs'))
      puts "You need to install Extjs library to #{GemInfo.test_app_root} test application."
      puts "You can do it running this command: rake test:prepare --with-extjs."
    elsif !File.exists?(File.join(GemInfo.test_app_root, 'config', 'database.yml'))
      puts "You need to create config/database.yml in #{GemInfo.test_app_root} test application."
    elsif !File.exists?(File.join(GemInfo.test_app_root, 'db', 'development.sqlite3'))
      puts "You need to run db:create and db:migrate in #{GemInfo.test_app_root} test application."
    else
      puts "Everything is fine. You can ran rake test now."
    end
  end

  desc "Prepare test application."
  task :prepare do |task_name|

    argument = ARGV.last
    if argument != task_name
      task argument.to_sym {}
      puts "Installing Extjs library for application in #{GemInfo.test_app_root}"
      install_extjs if argument =~ /with-extjs/
    end

    puts "Prepare Database for application in #{GemInfo.test_app_root}"
    system %(cd #{GemInfo.test_app_root} && ln config/database.sample.yml config/database.yml)
    system %(cd #{GemInfo.test_app_root} && bundle exec rake db:create && bundle exec rake db:migrate && bundle exec rake db:seed)

  end

end
