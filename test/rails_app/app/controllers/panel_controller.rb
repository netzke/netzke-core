class PanelController < ApplicationController
  def server_caller
    render :inline => "<%= netzke :server_caller %>", :layout => true
  end
  
  def aggregatee_loader
    render :inline => "<%= netzke :aggregatee_loader %>", :layout => true
  end
end