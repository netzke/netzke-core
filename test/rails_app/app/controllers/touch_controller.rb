class TouchController < ApplicationController
  def index
    component_name = params[:component].gsub("::", "_").underscore
    render :inline => "<%= netzke_touch :#{component_name}, :class_name => 'Touch::#{params[:component]}' %>", :layout => true
  end
end
