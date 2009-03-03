class NetzkeController < ActionController::Base

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
        Netzke::Base.config[:css].each do |path|
          f = File.new(path)
          res << f.read
        end
        render :text => res
      }
    end
  end
  
  def method_missing(action)
    respond_to do |format|
      format.js {
        render :text => "#{action}.js"
      }
      format.css {
        render :text => "#{action}.css"
      }
    end
  end
  
end