class CorrectMarkModifiedBy < ActiveRecord::Migration
  def self.up
    rename_column :marks, :modified_by_id_id, :modified_by_id
  end

  def self.down
    rename_column :marks, :modified_by_id, :modified_by_id_id
  end
end
