class ComponentThatHasActions < Netzke::Base
  
  action :some_action, :text => "Some action"
  
  action :another_action, :disabled => true, :text => "Disabled action"
  
  js_property :title, "Panel that has actions"
  
  js_property :bbar, [:some_action.action, :another_action.action]
  
  js_property :tbar, [{
    :xtype =>  'buttongroup',
    :columns => 3,
    :title => 'Clipboard',
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