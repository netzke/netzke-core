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
    ENV['EXTJS_SRC'] == 'cdn' || File.exists?(File.join(GemInfo.test_app_root, 'public', 'extjs'))
  end

  def self.ready?
    self.extjs_installed?
  end
end

# colorization
class String

  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def pink
    colorize(35)
  end
end
