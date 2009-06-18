class StudentGroup < ActiveRecord::Base
  named_scope :by_year, lambda { |year| { :conditions => { :year => year } } }
  
  def full_name
    self.year + self.letter
  end
end
