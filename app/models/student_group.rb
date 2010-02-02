class StudentGroup < ActiveRecord::Base
  has_many :students, :order => "last_name ASC, first_name ASC"
  
  named_scope :by_year, lambda { |year| { :conditions => { :year => year } } }
  
  def full_name
    "#{self.year} #{self.letter}"
  end
end
