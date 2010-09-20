class WidgetsController < ApplicationController
  def show
    widget_name = params[:widget].gsub("::", "__").underscore
    render :inline => "<%= netzke :#{widget_name}, :class_name => '#{params[:widget]}' %>", :layout => true
  end

  # Just a test for a pure Ext widget - not sure if it's useful.
  def ext
    widget_name = params[:widget].gsub("::", "__").underscore
    render :inline => "<%= ext :#{widget_name}, :xtype => 'panel', :html => 'blah', :title => 'Testik' %>", :layout => true
  end
end