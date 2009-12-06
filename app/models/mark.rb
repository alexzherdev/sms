class Mark < ActiveRecord::Base
  belongs_to :student
  belongs_to :schedule_item
  belongs_to :modified_by, :class_name => "Teacher"
  
  validates_presence_of :student, :schedule_item, :modified_by
end
