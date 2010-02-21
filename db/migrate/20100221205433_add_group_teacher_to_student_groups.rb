class AddGroupTeacherToStudentGroups < ActiveRecord::Migration
  def self.up
    add_column :student_groups, :group_teacher_id, :integer
  end

  def self.down
    remove_column :student_groups, :group_teacher_id
  end
end
