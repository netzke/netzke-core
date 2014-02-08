require 'spec_helper'

class DslDelegatedPropertiesBase < Netzke::Base
  include Netzke::Core::ConfigToDslDelegator

  delegates_to_dsl :title, :html
end

class DslDelegatedProperties < DslDelegatedPropertiesBase
  title "Title set via DSL"
  html "HTML set via DSL"
end

describe Netzke::Core::ConfigToDslDelegator do
  it "should enable delegating default config properties to DSL" do
    component = DslDelegatedProperties.new
    component.js_config.title.should == "Title set via DSL"
    component.js_config.html.should == "HTML set via DSL"
  end
end
