class Teacher < User
  def student_groups_for_register
    TeacherSubject.find_all_by_teacher_id(self).collect(&:student_group).uniq    
  end
  
  def subjects_for_register(group)
    TeacherSubject.find_all_by_teacher_id_and_student_group_id(self, group).collect(&:subject).sort
  end
  
  def can_edit_register?
    true
  end
end
