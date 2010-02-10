class Mark < ActiveRecord::Base
  MARK_VALUES = (0..10).to_a
  
  belongs_to :student
  belongs_to :schedule_item
  belongs_to :modified_by, :class_name => "Teacher"
  
  validates_presence_of :student, :schedule_item, :modified_by
  
  def self.for_register(group, subject, start_date, end_date)
    self.find(:all, :include => :schedule_item, :conditions => [ "schedule_items.student_group_id = ? and schedule_items.subject_id = ? and date between ? and ?", group.id, subject.id, start_date, end_date ])
  end
end
