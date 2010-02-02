class Role < ActiveRecord::Base
  has_and_belongs_to_many :acl_actions
  validates_presence_of :name
  
  class << self
    def admin
      @admin ||= find_by_name("Администратор")
    end
    
    def teacher
      @teacher ||= find_by_name("Учитель")
    end
  end
  
  def comma_separated_acl_action_ids=(ids)
    ids = ids.split(",").collect { |id| id.to_i }
    self.acl_action_ids = ids
  end
end