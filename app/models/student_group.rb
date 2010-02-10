class StudentGroup < ActiveRecord::Base
  has_many :students, :order => "last_name ASC, first_name ASC"
  
  default_scope :order => "year ASC, letter ASC"
  named_scope :by_year, lambda { |year| { :conditions => { :year => year } } }
  
  accepts_comma_separated_ids_for :students
  
  def full_name
    "#{self.year} #{self.letter}"
  end
end
