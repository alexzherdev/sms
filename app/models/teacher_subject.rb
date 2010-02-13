class TeacherSubject < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :subject
  belongs_to :student_group
  
  default_scope :include => [:teacher, :subject, :student_group]
  
  #  For rendering the thing to json.
  #
  def subject_name
    subject.name
  end
  
  #  For rendering the thing to json.
  #
  def student_group_name
    student_group.full_name
  end
end
