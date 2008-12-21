module Netzke
  class Widget < Base
    interface :method_one, :method_two
    def initial_aggregatees
      {
        :nested_one => {:widget_class_name => 'NestedWidgetOne'},
        :nested_two => {:widget_class_name => 'NestedWidgetTwo'}
      }
    end
  
    def available_permissions
      %w(read update)
    end
    
    def initial_config
      {
        :config_uno => true,
        :config_dos => false
      }
    end
  end

  class NestedWidgetOne < Base
  end

  class NestedWidgetTwo < Base
    def initial_aggregatees
      {
        :nested => {:widget_class_name => 'DeepNestedWidget'}
      }
    end
  end

  class DeepNestedWidget < Base
  end
end