class CreateYearMarks < ActiveRecord::Migration
  def self.up
    add_column :marks, :year_id, :integer
  end

  def self.down
    remove_column :marks, :year_id
  end
end
