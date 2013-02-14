class DslDelegatedPropertiesBase < Netzke::Base
  include Netzke::Core::ConfigToDslDelegator

  delegates_to_dsl :title, :html
end
