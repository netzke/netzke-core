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

begin
  require 'rvm'
rescue
  warn "Development tasks need RVM gem. Run `gem install rvm`, please."
  exit -1
end

# Super class for application configuration steps
# it should allow to perform step and to check if step is reday
class SetupStep
  def initialize(options = {})
    options.each_pair do |k, v|
      instance_eval("@#{k} = \"#{v.to_s}\"")
    end
  end

  def file_exists?(file)
    File.exist?(File.join(@path, file))
  end
end

# Step where we setup Extjs library to test application by creating link to folder with Extjs.
# It assumes that path to Extjs folder if set in ENV['EXTJS_HOME'] parameter, if it is nil
# message is prompted to user with suggestion to download it from github.
# Downloading and installation is performed in automatically.
class ExtjsStep < SetupStep

  def ready?
    file_exists?('public/extjs')
  end

  def perform
    return if ready?
    if ENV['EXTJS_HOME'].nil?
      print "You didn't specify EXTJS_HOME parameter. Would you like to install extjs from Github sources? [y/n]: "
      case STDIN.gets.strip
        when 'Y', 'y', 'j', 'J', 'yes' # j for Germans (Ja)
          ENV['EXTJS_HOME'] = File.join(TestConfig.netzke_gem_directory, 'extjs')
          abort("Can't download Extjs from Github") unless download_extjs(to: ENV['EXTJS_HOME'])
        when /\A[nN]o?\Z/ # n or no
          abort("Ok. Then re-run this task this way: rake EXTJS_HOME=path/to/extjs/folder test:app:prepare")
      end
    end
    install_extjs
  end

private

  # Download netzko-demo application from Github and extract Extjs from it.
  # Necessary option :to - folder where Extjs should be placed.
  def download_extjs(options = {})
    return unless (download_folder = options[:to])
    temp_folder = File.join(TestConfig.netzke_gem_directory, 'temp')
    demo_app_github_repo = "git://github.com/netzke/netzke-demo.git"
    temp_folder_exists = File.exist?(File.join(TestConfig.netzke_gem_directory, temp_folder))
    repo_name = demo_app_github_repo.match("\/([^\/]+).git$")[1]

    puts   "Creating temp directory."
    system %(mkdir -p #{temp_folder})

    puts   "Fetching Extjs from Github sources."
    system %(cd #{temp_folder} && git clone #{demo_app_github_repo} && mv ./#{repo_name}/public/extjs #{download_folder})

    puts   "Remove temp directory."
    system %(rm -rf #{temp_folder_exists ? File.join(temp_folder, repo_name) : temp_folder})
  end

  def install_extjs
    puts   "Link Extjs library with application in #{@path}."
    system %(ln -s #{ENV['EXTJS_HOME']} #{@path}/public/extjs)
  end

end

class DatabaseStep < SetupStep
  def ready?
    file_exists?('config/database.yml') && file_exists?('db/schema.rb')
  end

  def perform
    return if ready?
    RVM.gemset_use!(@gemset)

    puts "Prepare Database for application in #{@path}"
    system %(cd #{@path} && ln config/database.sample.yml config/database.yml)
    system %(cd #{@path} && bundle exec rake db:create && bundle exec rake db:migrate && bundle exec rake db:seed)
  end
end

class BundleStep < SetupStep
  def ready?
    (RVM.gemset_list << RVM.gemset.name).include?(@gemset)
  end

  def perform
    return if ready?
    RVM.gemset_create(@gemset)
    RVM.gemset_use!(@gemset)
    puts %(gem install bundler)
    puts %(cd #{@path} && bundle install)
    system %(gem install bundler)
    system %(cd #{@path} && bundle install)
  end

end

class TestApplication
  attr_accessor :name, :steps, :path

  def initialize(name, path)
    @name  = name
    @path  = path
    @rvm_gemset = "netzke-#{@name.gsub(' ', '').downcase}"
    @steps = [ ExtjsStep.new(path: @path),
               BundleStep.new(path: @path, gemset: @rvm_gemset),
               DatabaseStep.new(path: @path, gemset: @rvm_gemset) ]
  end

  def ready?
    @steps.map(&:ready?).all?
  end

  def prepare
    @steps.each(&:perform)
  end

  def test
    RVM.gemset_use!(@rvm_gemset)
    puts "Testing Netzke on #{@name} application."
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

    #def rails4_application
    #  @rails4_application ||= TestApplication.new("Rails 4", File.join(netzke_gem_directory, 'test', "rails4_core_test_app"))
    #end

    def test_applications
      @test_applications ||= [ rails3_application ] #, rails4_application]
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
      # TestConfig.rails4_application.test
    end

  end

end