class Widget < Netzke::Base
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
end

class NestedWidgetOne < Netzke::Base
end

class NestedWidgetTwo < Netzke::Base
  def initial_aggregatees
    {
      :nested => {:widget_class_name => 'DeepNestedWidget'}
    }
  end
end

class DeepNestedWidget < Netzke::Base
end

