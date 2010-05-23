class Teacher < User
  has_one :student_group, :foreign_key => "group_teacher_id"
  has_many :teacher_subjects
  
  #  Возвращает классы, в которых этот учитель ведет какие-нибудь предметы.
  #
  def student_groups_for_register
    TeacherSubject.find_all_by_teacher_id(self).collect(&:student_group).uniq    
  end
  
  #  Возвращает предметы, которые этот учитель ведет в данном классе.
  #
  #  * <tt>group</tt>:: Класс.
  #
  def subjects_for_register(group)
    TeacherSubject.find_all_by_teacher_id_and_student_group_id(self, group).collect(&:subject).sort
  end
  
  #  Учитель может редактировать журнал.
  #
  def can_edit_register?
    true
  end
end
