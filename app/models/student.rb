class Student < Person
  belongs_to :student_group
  
  validates_format_of :parent_email, :with => Authlogic::Regex.email, :allow_blank => true
  
  scope :unassigned, where(:student_group_id => nil)

  def student_group_name
    return nil if student_group.blank?
    student_group.full_name
  end
  
  def student_group_name=(name)
    return if name.blank?
    year = name.split(" ")[0].to_i
    letter = name.split(" ")[1]
    group = StudentGroup.find_or_create_by_year_and_letter(year, letter)
    self.student_group = group
  end
end