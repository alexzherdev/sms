# coding: utf-8

class Role < ActiveRecord::Base
  has_and_belongs_to_many :acl_actions
  validates_presence_of :name
  
  accepts_comma_separated_ids_for :acl_actions
  
  class << self
    def admin
      @admin ||= find_by_name("Администратор")
    end
    
    def teacher
      @teacher ||= find_by_name("Учитель")
    end
    
    def parent_role
      @parent_role ||= find_by_name("Родитель")
    end
    
    def reload!
      @admin = @teacher = @parent_role = nil
    end
  end
end