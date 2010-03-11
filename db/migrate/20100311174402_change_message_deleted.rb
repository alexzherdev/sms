class ChangeMessageDeleted < ActiveRecord::Migration
  def self.up
    change_column :messages, :deleted, :integer, :default => 0
    change_column :message_copies, :deleted, :integer, :default => 0
  end

  def self.down
    change_column :messages, :deleted, :boolean, :default => false
    change_column :message_copies, :deleted, :boolean, :default => false
  end
end
