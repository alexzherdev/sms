class ScheduleItem < ActiveRecord::Base
  belongs_to :subject
  belongs_to :student_group
  belongs_to :time_table_item
  belongs_to :class_room
  
  default_scope :include => [:subject, :student_group, :time_table_item, :class_room]
end
