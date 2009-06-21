class ScheduleItem < ActiveRecord::Base
  belongs_to :subject
  belongs_to :student_group
  belongs_to :lesson_time
  belongs_to :class_room
  
  default_scope :include => [:subject, :student_group, :lesson_time, :class_room]
end
