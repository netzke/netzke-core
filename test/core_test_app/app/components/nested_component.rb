class NestedComponent < Netzke::Base
  js_property :layout, :fit

  def configuration
    super.tap do |c|
      c[:items] = [:child.component]
    end
  end

  component :child,
    :class_name => "SimpleComponent",
    :layout => 'accordion',
    :items => [:grand_child_one.component, :grand_child_two.component],
    :components => {
      :grand_child_one => {:class_name => "SimpleComponent", :title => "Grand Child One"},
      :grand_child_two => {:class_name => "NestedComponent", :title => "Grand Child Two", :lazy_loading => true}
    }
end