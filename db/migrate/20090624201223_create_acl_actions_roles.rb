class CreateAclActionsRoles < ActiveRecord::Migration
  def self.up
    create_table :acl_actions_roles, :id => false do |t|
      t.timestamps

      t.references  :role
      t.references  :acl_action
    end
  end

  def self.down
    drop_table :acl_actions_roles
  end
end
