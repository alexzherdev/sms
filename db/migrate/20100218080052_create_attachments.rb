class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.string :data_file_name
      t.string :data_content_type
      t.integer :data_file_size
      t.integer :parent_id
      t.string :parent_type
      
      t.timestamps
    end
  end

  def self.down
    drop_table :attachments
  end
end
