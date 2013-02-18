class Actions < Netzke::Base
  action :simple_action do |a|
    a.icon = Netzke::Core.icons_uri + "/tick.png" # specify full icon uri
  end

  action :another_action do |a|
    a.disabled = true
    a.text = "Disabled action"
    a.icon = :accept # accept.png icon will be looked for in Netzke::Core.icons_uri
  end

  action :action_with_custom_handler do |c|
    c.text = "Action with custom handler"
    c.handler = :custom_action_handler
  end

  action :excluded_action do |c|
    c.excluded = true
  end

  def configure(c)
    super
    c.title = "Panel that has actions"
    c.bbar = [:simple_action, :another_action, :action_with_custom_handler, :excluded_action]
    c.tbar = [{
      :xtype =>  'buttongroup',
      :columns => 3,
      :title => 'A group',
      :items => [{
          :text => 'Paste',
          :scale => 'large',
          :rowspan => 3, :iconCls => 'add',
          :iconAlign => 'top',
          :cls => 'x-btn-as-arrow'
      },{
          :xtype => 'splitbutton',
          :text => 'Menu Button',
          :scale => 'large',
          :rowspan => 3,
          icon: uri_to_icon(:anchor), # use uri_to_icon helper to get the full icon uri
          :arrowAlign => 'bottom',
          :menu => [:simple_action]
      },{
          :xtype => 'splitbutton', :text => 'Cut', :menu => [:another_action]
      }, :another_action,
      {
          :menu => [:simple_action], :text => 'Format'
      }]
    }]
  end

  js_configure do |c|
    c.on_simple_action = <<-JS
      function(){
        this.setTitle("Simple action triggered");
      }
    JS

    c.on_another_action = <<-JS
      function(){
        this.update("Another action was triggered");
      }
    JS

    c.custom_action_handler = <<-JS
      function(){
        this.update("Custom action handler was called");
      }
    JS
  end
end
