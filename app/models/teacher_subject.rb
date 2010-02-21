class TeacherSubject < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :subject
  belongs_to :student_group
  
  default_scope :include => [:teacher, :subject, :student_group]
  
  #  Для удобства рендеринга в json.
  #
  def subject_name
    subject.name
  end
  
  #  Для удобства рендеринга в json.
  #
  def student_group_name
    student_group.full_name
  end
end
