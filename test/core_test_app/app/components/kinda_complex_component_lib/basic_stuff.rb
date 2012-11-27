module KindaComplexComponentLib
  # Note the use of ActiveSupport::Concern module
  module BasicStuff
    extend ActiveSupport::Concern

    included do
      action :some_action
      action :another_action

      js_configure do |c|
        c.extend = "Ext.tab.Panel"
        c.active_tab = 0

        # Calling main class' methods is simple
        c.on_some_action = <<-JS
          function(){ this.items.last().setTitle("Action triggered"); }
        JS

        # Another way of defining a JS method
        c.on_another_action = <<-JS
          function(){ this.items.first().setTitle("Another action triggered"); }
        JS
      end
    end

    def configure(c)
      super
      c.bbar = [:some_action, :another_action]
      c.items = [{:title => "Panel One"}, {:title => "Panel Two"}]
    end

  end
end
