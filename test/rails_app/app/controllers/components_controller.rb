class ComponentsController < ApplicationController
  def show
    component_name = params[:component].gsub("::", "_").underscore
    render :inline => "<%= netzke :#{component_name}, :class_name => '#{params[:component]}' %>", :layout => true
  end

  # Just a test for a pure Ext component - not sure if it's useful.
  def ext
    component_name = params[:component].gsub("::", "_").underscore
    render :inline => "<%= ext :#{component_name}, :xtype => 'panel', :html => 'blah', :title => 'Testik' %>", :layout => true
  end
end