class User < Person  
  belongs_to :role
  validates_presence_of :role_id
  
  acts_as_authentic
  
  def can_access?(signature)
    role.acl_actions.any? { |act| act.name == signature }    
  end
  
  def full_name
    "#{last_name} #{first_name}"
  end
end