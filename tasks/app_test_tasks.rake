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

def commented_sh(comment, command)
  puts(comment)
  system("#{command} > /dev/null")
end

def download_extjs(options = {})
  return false unless (extjs_home = options[:to])
  extjs_download_url = "http://cdn.sencha.io/ext-4.1.1a-gpl.zip"
  archive_name       = extjs_download_url.match(/[^\/]+$/)[0]
  extracted_folder   = archive_name.match(/^(.+)-gpl\.[^\.]+$/)[1]

  commented_sh("Downloading Extjs from #{extjs_download_url}".green, %(wget #{extjs_download_url})) &&
  commented_sh("Extracting Extjs from archive".green,                %(unzip #{archive_name}))      &&
  system(%(mkdir -p #{extjs_home}))                  &&
  system(%(mv #{extracted_folder}/* #{extjs_home}))  &&
  system(%(rmdir "#{extracted_folder}" && rm "#{archive_name}"))
end

def install_extjs
  extjs_home = File.join(GemInfo.gem_root, 'extjs')
  return false unless download_extjs(to: extjs_home)
  system %(ln -s #{extjs_home} #{File.join(GemInfo.test_app_root, 'public', 'extjs')})
end

task :test do
  if TestAppChecker.ready?
    system %(cd #{GemInfo.test_app_root} && rspec spec)
    system %(cd #{GemInfo.test_app_root} && cucumber features)
  else
    abort("Test application in #{GemInfo.test_app_root} is not ready. You can run rake test:check to see what is wrong.")
  end
end

namespace :test do

  desc "Checks if test application is ready for testing."
  task :install_extjs do
    puts "Installing Extjs library for application in #{GemInfo.test_app_root}".green
    if TestAppChecker.extjs_installed?
      puts "Extjs is already installed.".green
    else
      extjs_home = File.join(GemInfo.gem_root, 'extjs')
      if download_extjs(to: extjs_home)
        system(%(ln -s #{extjs_home} #{File.join(GemInfo.test_app_root, 'public', 'extjs')}))
      else
        abort "For some reason can't download Extjs. Try to do it manually. Sorry for inconvenience.".red
      end
    end
  end

  desc "Checks if test application is ready for testing."
  task :check do
    puts "Checking application in #{GemInfo.test_app_root} folder.".green
    if    !TestAppChecker.extjs_installed?
      puts "You need to #{'install Extjs library'.green} to #{GemInfo.test_app_root} test application."
      puts "You can do it by running " +
           "rake test:install_extjs".green
      puts "Or you can create a " +
           "symlink of Extjs folder to #{GemInfo.test_app_root}/public/extjs".green + " manually."
    elsif !TestAppChecker.database_config_exists?
      puts "You need to create config/database.yml in #{GemInfo.test_app_root} test application."
      puts "You can run #{'rake test:prepare'.green} to do it automatically."
    elsif !TestAppChecker.database_exists?
      puts "You need to run db:create and db:migrate in #{GemInfo.test_app_root} test application."
      puts "You can run #{'rake test:prepare'.green} to do it automatically."
    else
      puts "Everything is fine. You can ran rake test now.".green
    end
  end

  desc "Prepare test application."
  task :prepare do
    if !TestAppChecker.extjs_installed?
      print "Would you like to download and install Extjs for test application? [y/n]: ".green

      case STDIN.gets.strip
        when 'Y', 'y', 'j', 'J', 'yes' then # j for Germans (Ja)
          Rake::Task['test:install_extjs'].invoke
        else
          puts "Ok. Then you will need to add extjs folder and its content to #{GemInfo.test_app_root}/public manually.".green
      end
    end

    puts "Test application is configured. Now you are welcome to run rake test.".green
  end

end
