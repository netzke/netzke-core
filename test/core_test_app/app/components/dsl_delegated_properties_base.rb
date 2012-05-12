class DslDelegatedPropertiesBase < Netzke::Base
  include Netzke::ConfigToDslDelegator

  delegates_to_dsl :title, :html
end
