class WidgetsController < ApplicationController
  def show
    widget_name = params[:widget].gsub("::", "__").underscore
    render :inline => "<%= netzke :#{widget_name}, :class_name => '#{params[:widget]}' %>", :layout => true
  end
end