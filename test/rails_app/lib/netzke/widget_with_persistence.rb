module Netzke
  class WidgetWithPersistence < Widget::Base
    def default_config
      {
        :title => "No Title (yet!)",
        :persistent_config => true
      }.deep_merge super
    end
    
    def self.js_properties
      {
        :bbar => [{:text => "Tell server to store new title", :ref => "../button"}],
        :bug_server => <<-END_OF_JAVASCRIPT.l,
          function(){
            this.whatsUp();
            this.update('You should see the response from the server in the title bar the very next moment');
          }
        END_OF_JAVASCRIPT

        :init_component => <<-END_OF_JAVASCRIPT.l,
          function(){
            #{js_full_class_name}.superclass.initComponent.call(this);
            this.button.on('click', this.bugServer, this);
          }
        END_OF_JAVASCRIPT
      }
    end
    
    api :whats_up
    def whats_up(params)
      update_persistent_options(:title => "New Title!")
      {}
    end
    
  end
end