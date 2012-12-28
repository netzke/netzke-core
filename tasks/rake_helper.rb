#
#  Helpers for rake tasks.
#
#  GemInfo - class where info about gem is stored.
#
#  TestAppChecker - helps to check if test app is ready for testing
#

class GemInfo
  def self.gem_root
    @netzke_gem_root ||= File.expand_path('../..', __FILE__)
  end
  def self.test_app_root
    @test_app_root   ||= File.join(gem_root, 'test', 'core_test_app')
  end
end


class TestAppChecker
  def self.extjs_installed?
    File.exists?(File.join(GemInfo.test_app_root, 'public', 'extjs'))
  end

  def self.database_config_exists?
    File.exists?(File.join(GemInfo.test_app_root, 'config', 'database.yml'))
  end

  def self.database_exists?
    File.exists?(File.join(GemInfo.test_app_root, 'db', 'development.sqlite3'))
  end
end