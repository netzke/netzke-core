#
#  Helpers for rake tasks.
#
#  GemInfo - class where info about gem is stored.
#

class GemInfo
  def self.gem_root
    @netzke_gem_root ||= File.expand_path('../..', __FILE__)
  end
  def self.test_app_root
    @test_app_root   ||= File.join(gem_root, 'test', 'core_test_app')
  end
end
