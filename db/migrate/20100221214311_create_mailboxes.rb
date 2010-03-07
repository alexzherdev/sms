class CreateMailboxes < ActiveRecord::Migration
  def self.up
    create_table :mailboxes do |t|
      t.belongs_to :user
      t.timestamps
    end
  end

  def self.down
    drop_table :mailboxes
  end
end
