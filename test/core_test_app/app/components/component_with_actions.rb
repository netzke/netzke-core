class ComponentWithActions < Netzke::Base
  title "Panel that has actions"

  # Define actions as a hash
  action :another_action, :disabled => true, :text => "Disabled action", :icon => :accept

  # ... or as a block returning hash
  action :some_action do
    {:text => "Some Cool Action", :icon => Netzke::Core.icons_uri + "/delete.png"}
  end

  # ... or directly as a method
  def _my_action_action
    {:text => "Not used"}
  end


  js_property :bbar, [:some_action.action, :another_action.action]

  js_property :tbar, [{
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
        :iconCls => 'add',
        :iconAlign => 'top',
        :arrowAlign => 'bottom',
        :menu => [:some_action.action]
    },{
        :xtype => 'splitbutton', :text => 'Cut', :menu => [:another_action.action]
    }, :another_action.action,
    {
        :menu => [:some_action.action], :text => 'Format'
    }]
  }]

  js_method :on_some_action, <<-JS
    function(){
      this.update("Some action was triggered");
    }
  JS

  js_method :on_another_action, <<-JS
    function(){
      this.update("Another action was triggered");
    }
  JS

end
