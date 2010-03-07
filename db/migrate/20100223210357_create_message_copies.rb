class CreateMessageCopies < ActiveRecord::Migration
  def self.up
    create_table :message_copies do |t|
      t.belongs_to :message
      t.belongs_to :recipient
      t.belongs_to :folder
      t.integer :status
      t.timestamps
    end
  end

  def self.down
    drop_table :message_copies
  end
end
