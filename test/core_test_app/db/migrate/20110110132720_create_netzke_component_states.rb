class CreateNetzkeComponentStates < ActiveRecord::Migration
  def self.up
    create_table :netzke_component_states do |t|
      t.string :component
      t.integer :user_id
      t.integer :role_id
      t.text :value

      t.timestamps
    end

    add_index :netzke_component_states, :component
    add_index :netzke_component_states, :user_id
    add_index :netzke_component_states, :role_id
  end

  def self.down
    drop_table :netzke_component_states
  end
end
