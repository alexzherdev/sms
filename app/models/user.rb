class User < Person  
  belongs_to :role
  
  validates_presence_of :role_id
  
  acts_as_authentic
  
  def can_access?(signature)
    role.acl_actions.any? { |act| act.name == signature }    
  end
  
  def children
    Student.find(:all, :conditions => [ "parent1_id = ? or parent2_id = ?", self.id, self.id ])
  end

  #  Should be overridden for all user types browsing registers.
  #
  def student_groups_for_register
    children.collect(&:student_group).compact.uniq
  end
  
  #  Should be overridden for all user types browsing registers.
  #
  def subjects_for_register(group)
    Subject.find_all_by_year(group.year).sort
  end
  
  #  Should be overridden for all user types browsing registers.
  #
  def can_edit_register?
    false
  end
end