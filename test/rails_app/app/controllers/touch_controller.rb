class TouchController < ApplicationController
  def index
    component_name = params[:component].gsub("::", "_").underscore
    render :inline => "<%= netzke :#{component_name}, :class_name => 'Touch::#{params[:component]}' %>", :layout => true
  end
end
