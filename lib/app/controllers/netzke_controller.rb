class NetzkeController < ApplicationController
  
  # Collect javascripts from all plugins that registered it in Netzke::Base.config[:javascripts]
  # TODO: caching
  # caches_action :netzke
  def netzke
    respond_to do |format|
      format.js {
        res = ""
        Netzke::Widget::Base.config[:javascripts].each do |path|
          f = File.new(path)
          res << f.read
        end
        render :text => res.strip_js_comments
      }
      
      format.css {
        res = ""
        Netzke::Widget::Base.config[:stylesheets].each do |path|
          f = File.new(path)
          res << f.read
        end
        render :text => res
      }
    end
  end
  
  # Main dispatcher of the HTTP requests. The URL contains the name of the widget, 
  # as well as the method of this widget to be called, according to the double underscore notation. 
  # E.g.: some_grid__post_grid_data.
  def method_missing(method_name)
    widget_name, *action = method_name.to_s.split('__')
    widget_name = widget_name.to_sym
    action = !action.empty? && action.join("__").to_sym
  
    if action
      w_instance = Netzke::Widget::Base.instance_by_config(Netzke::Main.session[:netzke_widgets][widget_name])
      # only widget's actions starting with "api_" are accessible from outside (security)
      api_action = action.to_s.index('__') ? action : "api_#{action}"
      render :text => w_instance.send(api_action, params), :layout => false
    else
      super
    end
  end
  
end