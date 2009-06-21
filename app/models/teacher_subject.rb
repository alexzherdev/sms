class TeacherSubject < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :subject
  belongs_to :student_group
  
  default_scope :include => [:teacher, :subject, :student_group]
end
