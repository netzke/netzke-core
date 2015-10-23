require_relative './extension_one'
require_relative './extension_two'

class ComponentWithExtensions < Netzke::Base
  include ExtensionOne
  include ExtensionTwo
end
