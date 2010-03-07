class CreateMailboxFolders < ActiveRecord::Migration
  def self.up
    create_table :mailbox_folders do |t|
      t.belongs_to :mailbox
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :mailbox_folders
  end
end
