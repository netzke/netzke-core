class NetzkeController < ActionController::Base

  def index
    redirect_to :action => :test_widgets
  end

  # collect javascripts from all plugins that registered it in Netzke::Base.config[:javascripts]
  def netzke
    respond_to do |format|
      format.js {
        res = ""
        Netzke::Base.config[:javascripts].each do |path|
          f = File.new(path)
          res << f.read
        end
        render :text => res.strip_js_comments
      }
      
      format.css {
        res = ""
        Netzke::Base.config[:stylesheets].each do |path|
          f = File.new(path)
          res << f.read
        end
        render :text => res
      }
    end
  end
  
  def method_missing(method_name)
    widget_location = params[:location]
    widget_name, *action = method_name.to_s.split('__')
    widget_name = widget_name.to_sym
    action = !action.empty? && action.join("__").to_sym
  
    if action
      w_instance = Netzke::Base.instance_by_config(Netzke::Base.session[:netzke_widgets][widget_name])
      
      # Rails.logger.debug "!!! w_instance: #{w_instance.inspect}\n"
      
      # only widget's actions starting with "api_" are accessible from outside (security)
      api_action = action.to_s.index('__') ? action : "api_#{action}"

      

      # widget module
      # widget_class = "Netzke::#{self.class.widget_config_storage[widget][:widget_class_name]}".constantize

      # instantiate the server part of the widget
      # widget_instance = widget_class.new(self.class.widget_config_storage[widge_name])

      render :text => w_instance.send(api_action, params), :layout => false
    else
      super
    end
  end
  
end