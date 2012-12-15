# Netzke development tasks:
# Task for tests performing :
#
#      test:app         - run tests on all test rails applications, it will run consequentially
#                         `rspec spec` and `cucumber features` for each application
#
#      test:app:prepare - prepare test applications for testing, EXTJS_HOME should be specified
#                         to be pointing on folder with necessary extjs library, in other case it will
#                         try to fetch it from sencha.com. It makes symbolic links to extjs folder in
#                         each application.

# checks
# check if public/extjs exists
# check if config/database.yml exists
# check if db/schema.rb exists
# check if Gemfile.lock exists

# install ExtJs on test app
# find extjs or fetch it from internet, make symbolic links to public folders
# symbolic link to database.yml
# rake db:create && rake db:migrate
# create gemset && bundle install

class Step
  attr_accessor :path

  def initialize(path)
    @path = path
  end

  def file_exists?(file)
    File.exist?(File.join(@path, file))
  end
end

class ExtjsStep < Step

  def ready?
    file_exists?('public/extjs')
  end

  def perform
    if ENV['EXTJS_HOME'].nil?
      print "You didn't specify EXTJS_HOME parameter. Would you like to install it from Github sources? [y/n]: "
      case gets.strip
        when 'Y', 'y', 'j', 'J', 'yes' # j for Germans (Ja)
          ENV['EXTJS_HOME'] = File.join(TestConfig.netzke_gem_directory, 'extjs')
          download_extjs(to: ENV['EXTJS_HOME'])
        when /\A[nN]o?\Z/ # n or no
          abort("Ok. Then re-run this task this way: rake EXTJS_HOME=path/to/extjs/folder test:app:prepare")
      end
    end
    install_extjs
  end

private

  def download_extjs(options = {})
    # Download Extjs from demo application
    return unless (download_folder = options[:to])
    temp_folder = File.join(TestConfig.netzke_gem_directory, 'temp')
    demo_app_github_repo = "git://github.com/netzke/netzke-demo.git"
    temp_folder_exists = File.exist?(File.join(TestConfig.netzke_gem_directory, temp_folder))
    system %(mkdir -p #{temp_folder})
    repo_name = demo_app_github_repo.match("\/([^\/]+).git$")[1]
    system %(cd #{temp_folder} && git clone #{demo_app_github_repo} && mv ./#{repo_name}/public/extjs #{download_folder})
    system %(rm -rf #{temp_folder_exists ? File.join(temp_folder, repo_name) : temp_folder})
  end

  def install_extjs
    system %(ln -f #{ENV['EXTJS_HOME']} #{@path}/public/extjs)
  end

end

class DatabaseStep < Step
  def ready?
    file_exists?('config/database.yml') && file_exists?('db/schema.rb')
  end

  def perform
    system %(cd #{@path} && rake db:create && rake db:migrate)
  end
end

class BundleStep < Step

  def ready?
    file_exists?('Gemfile.lock')
  end

  def perform
    system %(cd #{@path} && bundle install)
  end

end

class TestApplication
  attr_accessor :name, :steps, :path

  def initialize(name, path)
    @name  = name
    @path  = path
    @steps = [ ExtjsStep.new(@path), DatabaseStep.new(@path), BundleStep.new(@path) ]
  end

  def ready?
    @steps.map(&:ready?).all?
  end

  def prepare
    @steps.each(&:perform)
  end

  def test
    system %(cd #{@path} && bundle exec rspec spec)
    system %(cd #{@path} && bundle exec cucumber features)
  end

end

class TestConfig
  class << self
    def netzke_gem_directory
      @netzke_gem_directory ||= File.expand_path('../..', __FILE__)
    end

    def rails3_application
      @rails3_application ||= TestApplication.new("Rails 3", File.join(netzke_gem_directory, 'test', "core_test_app"))
    end

    def rails4_application
      @rails4_application ||= TestApplication.new("Rails 4", File.join(netzke_gem_directory, 'test', "rails4_core_test_app"))
    end

    def test_applications
      @test_applications ||= [rails3_application, rails4_application]
    end
  end
end

namespace :test do

  desc "Test Netzke work within Rails applications"
  task :app do
    # check if apps have all they need
    if !TestConfig.test_applications.each(&:ready?).all?
      abort('Not all applications are ready for testing. Try to run `rake test:app:prepare`.')
    end
    Rake::Task['test:app:rails3'].invoke
    Rake::Task['test:app:rails4'].invoke
  end

  namespace :app do

    # Specify extjs directory with EXTJS_HOME parameter
    desc "Test Netzke with Rails application"
    task :prepare do
      TestConfig.test_applications.each(&:prepare)
    end

    desc "Test Netzke within Rails ~>3.2.9 application"
    task :rails3 do
      TestConfig.rails3_application.test
    end

    desc "Test Netzke within Rails 4 application"
    task :rails4 do
      TestConfig.rails4_application.test
    end

  end

end