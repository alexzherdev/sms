class AlterRolesUsersRelationship < ActiveRecord::Migration
  def self.up
    drop_table :roles_users
    add_column :people, :role_id, :integer, :null => false
  end

  def self.down
    remove_column :people, :role_id
    
    create_table :roles_users do |t|
      t.references :role
      t.references :user
    end
  end
end
