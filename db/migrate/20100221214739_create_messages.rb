class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.belongs_to :mailbox
      t.string :subject
      t.text :body
      t.integer :status
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
