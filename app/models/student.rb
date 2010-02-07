class Student < Person
  belongs_to :student_group
  
  validates_format_of :parent_email, :with => Authlogic::Regex.email, :allow_blank => true
end