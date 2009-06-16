class CreateTeacherSubjects < ActiveRecord::Migration
  def self.up
    create_table :teacher_subjects do |t|
      t.integer :teacher_id
      t.integer :subject_id
      t.integer :student_group_id
      t.timestamps
    end
  end
  
  def self.down
    drop_table :teacher_subjects
  end
end
