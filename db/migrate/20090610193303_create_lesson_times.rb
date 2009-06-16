class CreateLessonTimes < ActiveRecord::Migration
  def self.up
    create_table :lesson_times do |t|
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end
  end

  def self.down
    drop_table :lesson_times
  end
end
