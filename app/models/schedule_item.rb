class ScheduleItem < ActiveRecord::Base
  belongs_to :subject
  belongs_to :student_group
  belongs_to :time_table_item
  belongs_to :class_room
  
  default_scope :include => [:subject, :student_group, :time_table_item, :class_room]
  
  def self.grade_report(student, start_date, end_date)
    self.find(
      :all,
      :select => "schedule_items.*, marks.date, subjects.name, marks.mark",
      :joins => "LEFT JOIN marks ON marks.schedule_item_id = schedule_items.id AND marks.student_id =#{student.id}",
      :include => :subject,
      :conditions => ["schedule_items.student_group_id = ? and marks.date BETWEEN ? and ?",
        student.student_group_id, start_date, end_date],
      :order => :week_day
    )
  end
end
