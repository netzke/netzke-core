module Netzke
  module Core
    module Version
      MAJOR = 0
      MINOR = 10
      PATCH = 0
      PRE   = 'rc1'

      STRING = [MAJOR, MINOR, PATCH, PRE].compact.join('.')
    end
  end
end
