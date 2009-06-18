class LessonTime < ActiveRecord::Base
  FIRST_LESSON_START = Time.utc 2009,1,1,8,0,0
  LESSON_LENGTH = 45.minutes
  BREAK_LENGTH = 10.minutes
  
  WEEK_DAYS = (1..6).to_a
  validates_presence_of :start_time
  validates_presence_of :end_time

  default_scope :order => "start_time"
  
end
