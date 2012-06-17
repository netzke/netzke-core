class ComponentWithIncludedJs < Netzke::Base
  class_attribute :title
  self.title = "My title"

  def self.js_configure(c)
    c.include "#{File.dirname(__FILE__)}/included.js"

    c.extend = "Netzke.ComponentWithIncludedJs"

    # c.method :on_print_message, <<-JS
    #   function(){
    #     this.updateBodyWithMessage("Some message " + "shown in the body");
    #   }
    # JS

    # c.property :active_tab, 0
    # c.property :title, self.title

    c.on_print_message = <<-JS
      function(){
        this.updateBodyWithMessage("Some message " + "shown in the body");
      }
    JS

    c.active_tab = 0
    c.title = title
  end

  # js_configure do |c|
  #   c.include "#{File.dirname(__FILE__)}/included.js"

  #   c.extend "Netzke.ComponentWithIncludedJs"

  #   c.method :on_print_message, <<-JS
  #     function(){
  #       this.updateBodyWithMessage("Some message " + "shown in the body");
  #     }
  #   JS

  #   c.property :active_tab, 0
  #   c.property :title, self.title

  #   # prototype do |c|
  #   #   c.active_tab = 0
  #   #   c.on_print_message = method <<-JS
  #   #     function(){
  #   #       this.updateBodyWithMessage("Some message " + "shown in the body");
  #   #     }
  #   #   JS
  #   # end
  # end

  # js_include "#{File.dirname(__FILE__)}/included.js"

  # js_base_class "Netzke.ComponentWithIncludedJs"

  action :print_message

  # configure do |c|
  #   super(c)
  #   c.bbar = [:print_message]
  # end

  def configure
    super
    config.bbar = [:print_message]
  end

  # js_method :on_print_message, <<-JS
  #   function(){
  #     this.updateBodyWithMessage("Some message " + "shown in the body");
  #   }
  # JS
end
