class User < Person  
  has_and_belongs_to_many :roles
  
  acts_as_authentic
  
  def can_access?(signature)
    return self.roles.any? do |role|
      role.acl_actions.any? { |act| act.name == signature }
    end    
  end
end