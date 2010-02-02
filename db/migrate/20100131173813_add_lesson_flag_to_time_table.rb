class AddLessonFlagToTimeTable < ActiveRecord::Migration
  def self.up
    add_column :time_table_items, :item_type, :integer
  end

  def self.down
    remove_column :time_table_items, :item_type
  end
end
