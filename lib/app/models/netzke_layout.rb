class NetzkeLayout < ActiveRecord::Base
  UNRELATED_ATTRS = %w(created_at updated_at position layout_id)

  # Multi user support
  def self.user
    @@user ||= nil
  end
  
  def self.user=(user)
    @@user = user
  end
  
  def self.user_id
    user && user.id
  end
  
  # normal create, but with a user_id merged-in
  def self.create_with_user(config)
    create(config.merge(:user_id => user_id))
  end
  
  def layout_items
    items_class.constantize.find_all_by_layout_id(id, :order => 'position')
  end
  
  def self.by_widget(widget_name)
    self.find(:first, :conditions => {:widget_name => widget_name, :user_id => user_id})
  end

  def move_item(old_index, new_index)
    layout_item = layout_items[old_index]
    layout_item.remove_from_list
    layout_item.insert_at(new_index + 1)
  end

  def items_hash
    layout_items.map(&:attributes).map{|item| item.delete_if{|k,v| UNRELATED_ATTRS.include?(k)}}.map{ |i| i.convert_keys{ |k| k.to_sym } }
  end
  
end