class AllowNullRole < ActiveRecord::Migration
  def self.up
    change_column :people, :role_id, :integer, :null => true
  end

  def self.down
    change_column :people, :role_id, :integer, :null => false 
  end
end
