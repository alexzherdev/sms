class AddDeletedToMessages < ActiveRecord::Migration
  def self.up
    add_column :messages, :deleted, :boolean, :default => false
    add_column :message_copies, :deleted, :boolean, :default => false
  end

  def self.down
    remove_column :message_copies, :deleted
    remove_column :messages, :deleted
  end
end
