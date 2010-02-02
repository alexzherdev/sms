class RenameLessonTimes < ActiveRecord::Migration
  def self.up
    rename_table :lesson_times, :time_table_items
    rename_column :schedule_items, :lesson_time_id, :time_table_item_id
  end

  def self.down
    rename_table :time_table_items, :lesson_times
    rename_column :schedule_items, :time_table_item_id, :lesson_time_id
  end
end
