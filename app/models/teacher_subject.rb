class TeacherSubject < ActiveRecord::Base
  belongs_to :teacher
  belongs_to :subject
  belongs_to :student_group
end
