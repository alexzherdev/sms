class Role < ActiveRecord::Base
  has_and_belongs_to_many :acl_actions
  
  class << self
    def admin
      @admin ||= find_by_name("Администратор")
    end
    
    def teacher
      @teacher ||= find_by_name("Учитель")
    end
  end
end