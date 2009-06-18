class CreateSubjectsClassRoomsHabtm < ActiveRecord::Migration
  def self.up
    create_table :class_rooms_subjects, :id => false do |t|
      t.integer :class_room_id
      t.integer :subject_id
    end
  end

  def self.down
    drop_table :class_rooms_subjects
  end
end
