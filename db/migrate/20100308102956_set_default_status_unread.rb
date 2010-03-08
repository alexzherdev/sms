class SetDefaultStatusUnread < ActiveRecord::Migration
  def self.up
    change_column :message_copies, :status, :integer, :default => Mailbox::MessageCopy::UNREAD
  end

  def self.down
  end
end
