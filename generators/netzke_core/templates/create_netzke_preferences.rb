class CreateNetzkePreferences < ActiveRecord::Migration
  def self.up
    create_table :netzke_preferences do |t|
      t.string :name
      t.string :pref_type
      t.string :value
      t.integer :user_id
      t.integer :role_id
      t.string :widget_name

      t.timestamps
    end
  end

  def self.down
    drop_table :netzke_preferences
  end
end
