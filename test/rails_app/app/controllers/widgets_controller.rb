# TODO: rename to "widgets_controller", and make loading widgets DRY
class WidgetsController < ApplicationController
  def show
    render :inline => "<%= netzke :#{params[:widget]} %>", :layout => true
  end
  
  # def server_caller
  #   render :inline => "<%= netzke :server_caller %>", :layout => true
  # end
  # 
  # def aggregatee_loader
  #   render :inline => "<%= netzke :aggregatee_loader %>", :layout => true
  # end
  # 
  # def panel_with_actions
  #   render :inline => "<%= netzke :panel_with_actions %>", :layout => true
  # end
end