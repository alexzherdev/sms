class CreateAclActions < ActiveRecord::Migration
  def self.up
    create_table :acl_actions do |t|
      t.string :name
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :acl_actions
  end
end
