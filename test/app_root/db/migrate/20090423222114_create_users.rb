class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :login
      t.integer :role_id
    end
  end

  def self.down
    drop_table :users
  end
end
