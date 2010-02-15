class CreateTermMarks < ActiveRecord::Migration
  def self.up
    add_column :marks, :term_id, :integer
  end

  def self.down
    remove_column :marks, :term_id
  end
end
