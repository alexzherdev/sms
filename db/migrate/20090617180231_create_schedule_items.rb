class CreateScheduleItems < ActiveRecord::Migration
  def self.up
    create_table :schedule_items do |t|
      t.integer :week_day
      t.integer :lesson_time_id
      t.integer :student_group_id
      t.integer :subject_id
      t.integer :class_room_id
      t.timestamps
    end
  end
  
  def self.down
    drop_table :schedule_items
  end
end
