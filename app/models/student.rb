class Student < Person
  belongs_to :student_group
  
  validates_format_of :parent_email, :with => Authlogic::Regex.email, :allow_blank => true
  
  named_scope :unassigned, :conditions => { :student_group_id => nil }
end