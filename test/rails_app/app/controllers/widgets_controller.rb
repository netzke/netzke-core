# TODO: rename to "widgets_controller", and make loading widgets DRY
class WidgetsController < ApplicationController
  def show
    inline_code = case params[:widget]
    when /.+_deep_scoped_widget$/
      "<%= netzke :#{params[:widget]}, :class_name => 'ScopedWidgets::DeepScopedWidgets::#{params[:widget].camelize}' %>"
    when /.+_scoped_widget$/
      "<%= netzke :#{params[:widget]}, :class_name => 'ScopedWidgets::#{params[:widget].camelize}' %>"
    else
      "<%= netzke :#{params[:widget]} %>"
    end
    render :inline => inline_code, :layout => true
  end
end