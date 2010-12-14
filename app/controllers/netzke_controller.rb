class NetzkeController < ApplicationController

  # Collect javascripts and stylesheets from all plugins that registered it in Netzke::Core.javascripts
  # TODO: caching
  # caches_action :netzke
  def ext
    respond_to do |format|
      format.js {
        res = initial_dynamic_javascript << "\n"
        Netzke::Core.javascripts.each do |path|
          f = File.new(path)
          res << f.read
        end

        # Ext-specific stuff
        res << File.new(File.expand_path("../../../javascripts/ext.js", __FILE__)).read

        render :text => defined?(::Rails) && ::Rails.env.production? ? res.strip_js_comments : res
      }

      format.css {
        res = ""
        Netzke::Core.stylesheets.each do |path|
          f = File.new(path)
          res << f.read
        end
        render :text => res
      }
    end
  end

  def touch
    respond_to do |format|
      format.js {
        res = initial_dynamic_javascript << "\n"

        Netzke::Core.javascripts.each do |path|
          f = File.new(path)
          res << f.read
        end

        res << File.new(File.expand_path("../../../javascripts/touch.js", __FILE__)).read

        render :text => defined?(::Rails) && ::Rails.env.production? ? res.strip_js_comments : res
      }

      format.css {
        res = ""
        Netzke::Core.stylesheets.each do |path|
          f = File.new(path)
          res << f.read
        end
        render :text => res
      }
    end
  end


  # Main dispatcher of the HTTP requests. The URL contains the name of the component,
  # as well as the method of this component to be called, according to the double underscore notation.
  # E.g.: some_grid__post_grid_data.
  def method_missing(method_name)
    component_name, *action = method_name.to_s.split('__')
    component_name = component_name.to_sym
    action = !action.empty? && action.join("__").to_sym

    if action
      w_instance = Netzke::Base.instance_by_config(Netzke::Core.session[:netzke_components][component_name])
      # only component's actions starting with "endpoint_" are accessible from outside (security)
      endpoint_action = action.to_s.index('__') ? action : "_#{action}_ep_wrapper"
      render :text => w_instance.send(endpoint_action, params), :layout => false
    else
      super
    end
  end

  private
    # Generates initial javascript code that is dependent on Rails environement
    def initial_dynamic_javascript
      res = []
      res << %(Ext.Ajax.extraParams = {authenticity_token: '#{form_authenticity_token}'}; // Rails' forgery protection)
      res << %{Ext.ns('Netzke');}
      res << %{Netzke.RelativeUrlRoot = '#{ActionController::Base.config.relative_url_root}';}
      res << %{Netzke.RelativeExtUrl = '#{ActionController::Base.config.relative_url_root}/extjs';}
      res.join("\n")
    end

end
