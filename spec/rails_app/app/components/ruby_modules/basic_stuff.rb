class RubyModules < Netzke::Base
  # Note the use of ActiveSupport::Concern module
  module BasicStuff
    extend ActiveSupport::Concern

    included do
      action :some_action
      action :another_action

      client_class do |c|
        c.extend = "Ext.tab.Panel"
      end
    end

    def configure(c)
      super
      c.bbar = [:some_action, :another_action]
      c.items = [{:title => "Panel One"}, {:title => "Panel Two"}]
    end
  end
end
