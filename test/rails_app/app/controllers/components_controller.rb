class ComponentsController < ApplicationController
  def index
    component_name = params[:component].gsub("::", "_").underscore
    render :inline => "<%= netzke :#{component_name}, :class_name => '#{params[:component]}' %>", :layout => true
  end

  # For panel_with_autoload
  def autoloaded_content
    render :inline => "<%= netzke :simple_panel, :height => 300, :bbar => ['->', 'Some text'], :html => 'Autoloaded Panel' %>", :layout => "nested"
  end

  # Just a test for a pure Ext component - not sure if it's useful.
  def ext
    component_name = params[:component].gsub("::", "_").underscore
    render :inline => "<%= ext :#{component_name} %>", :layout => true
  end
end