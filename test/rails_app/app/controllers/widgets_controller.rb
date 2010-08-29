# TODO: rename to "widgets_controller", and make loading widgets DRY
class WidgetsController < ApplicationController
  def show
    if params[:widget] =~ /.+_scoped_widget$/
      render :inline => "<%= netzke :#{params[:widget]}, :class_name => 'ScopedWidgets::#{params[:widget].camelize}' %>", :layout => true
    else
      render :inline => "<%= netzke :#{params[:widget]} %>", :layout => true
    end
  end
end