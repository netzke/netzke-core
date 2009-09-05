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
  
  #
  # Primitive tests to quickly test the widgets
  #
  
  # FormPanel
  netzke :form_panel, :persistent_config => false, :label_align => "top", :columns => [
    {:name => 'field_one', :xtype => 'textarea'},
    {:name => 'field_two', :xtype => 'textarea'}
  ]
  
  # BorderLayoutPanel
  netzke :border_layout_panel, :regions => {
    :west => {
      :widget_class_name => "Panel",
      :region_config => {:width => 300, :split => true}
    },
    :center => {
      :widget_class_name => "Panel"
    }
  }
  
  # TabPanel
  netzke :tab_panel, :items => [{
    :widget_class_name => "Panel",
    :ext_config => {
      :html => "Panel 1",  
    },
    :active => true
  },{
    :widget_class_name => "Panel",
    :ext_config => {
      :html => "Panel 2",  
    }
  }]
  
  # AccordionPanel
  netzke :accordion_panel, :items => [{
    :widget_class_name => "Panel",
    :ext_config => {
      :html => "Panel 1",
    }
    # :active => true
  },{
    :widget_class_name => "Panel",
    :ext_config => {
      :html => "Panel 2",  
    }
  }]
  
  # BasicApp
  netzke :basic_app

  def test_widgets
    html = "<h3>Quick primitive widgets tests</h3>"
    
    self.class.widget_config_storage.each_key.map(&:to_s).sort.each do |w|
      html << "<a href='#{w}_test'>#{w.to_s.humanize}</a><br/>\n"
    end
    
    render :text => html
  end

end