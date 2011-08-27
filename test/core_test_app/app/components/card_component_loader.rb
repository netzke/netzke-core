class CardComponentLoader < Netzke::Base
  js_property :layout, :card

  action :load_server_caller
  action :load_extended_server_caller

  js_property :bbar, [:load_server_caller.action, :load_extended_server_caller.action]

  component :server_caller
  component :extended_server_caller

  js_method :on_load_server_caller, <<-JS
    function(){
      var existing = this.items.findBy(function(i){ return i.getId() == this.getId() + "__server_caller"}, this);
      if (existing) this.getLayout().setActiveItem(existing); else this.loadNetzkeComponent({name: 'server_caller', container: this, append: true, callback: function(el){this.getLayout().setActiveItem(el)}, scope: this});
    }
  JS

  js_method :on_load_extended_server_caller, <<-JS
    function(){
      var existing = this.items.findBy(function(i){ return i.getId() == this.getId() + "__extended_server_caller"}, this);
      if (existing) this.getLayout().setActiveItem(existing); else this.loadNetzkeComponent({name: 'extended_server_caller', container: this, append: true, callback: function(el){this.getLayout().setActiveItem(el)}, scope: this});
    }
  JS
end