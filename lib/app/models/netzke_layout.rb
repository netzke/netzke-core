class NetzkeLayout < ActiveRecord::Base
  # has_many :layout_items#, :class_name => "ExtWidget::LayoutItem", :order => :position
  # has_many :objects, :class_name => "Objects", :foreign_key => "class_name_id"
  # belongs_to :role
  # belongs_to :user

  UNRELATED_ATTRS = %w(created_at updated_at position layout_id)

  def self.user_id
    @@user_id ||= nil
  end
  
  def layout_items
    items_class.constantize.find_all_by_layout_id(id, :order => 'position')
  end
  
  #   
  # def self.user_id=(user_id)
  #   @@user_id = user_id
  # end
  # 
  # def self.layout_items(widget_name)
  #   layout = self.layout(widget_name)
  #   layout.nil? ? nil : layout.layout_items.map(&:attributes).map{|item| item.delete_if{|k,v| UNRELATED_ATTRS.include?(k)}}
  # end
  # 
  def self.by_widget(widget_name)
    self.find(:first, :conditions => {:widget_name => widget_name, :user_id => self.user_id})
  end

  def move_item(old_index, new_index)
    layout_item = layout_items[old_index]
    layout_item.remove_from_list
    layout_item.insert_at(new_index + 1)
  end

  # def self.layout_items(widget_name)
  #   layout = self.by_widget(widget_name)
  #   if layout
  #     layout.layout_items
  #   else
  #     # create new layout and fill it out with default values
  #     layout = Layout.create({:widget_name => widget_name, :user_id => self.user_id})
  #   end
  # end
  
  def items_hash
    layout_items.map(&:attributes).map{|item| item.delete_if{|k,v| UNRELATED_ATTRS.include?(k)}}.map{ |i| i.convert_keys{ |k| k.to_sym } }
  end
 
  # if layout items are provided, use them instead of defaults (exsposed) layout items, but merge their configs with the default
  # def self.create_layout_for_widget(widget_name, data_class_name, layout_item_class_name, items = nil)
  #   layout = self.create(:widget_name => widget_name, :items_class => layout_item_class_name, :user_id => self.user_id)
  #   data_class = data_class_name.constantize
  #   layout_item_class = layout_item_class_name.constantize
  #   
  #   
  #   if items.nil?
  #     complete_items = data_class.exposed_columns
  #   else
  #     # normalize columns
  #     columns = columns.
  #     default_columns = data_class.exposed_columns.map{|c| c.is_a?(Symbol) ? {:name => c} : c}
  #     columns.each
  #   
  #   complete_columns = columns.nil? ?  : columns
  #   complete_columns.each do |c|
  #     config = c.is_a?(Hash) ? c : {:name => c}
  #     # we have to merge layout_id in order to have :position set up properly
  #     item = layout_item_class.create_with_defaults(config.merge({:layout_id => layout.id}), data_class)
  #   end
  #   layout
  # end
  
end