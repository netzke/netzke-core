module Netzke
  module Core
    module Version
      MAJOR = 0
      MINOR = 6
      PATCH = 0
      BUILD = 'beta'

      STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')
    end
  end
end