class AddTypeToMarks < ActiveRecord::Migration
  def self.up
    add_column :marks, :type, :string
  end

  def self.down
    remove_column :marks, :type
  end
end
