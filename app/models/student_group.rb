class StudentGroup < ActiveRecord::Base
  has_many :students, :order => "last_name ASC, first_name ASC, middle_name ASC"
  belongs_to :group_teacher, :class_name => "Teacher"
  
  default_scope :order => "year ASC, letter ASC"
  named_scope :by_year, lambda { |year| { :conditions => { :year => year } } }
  
  accepts_comma_separated_ids_for :students
  
  #define_index do 
  #  indexes [year, letter], :as => :full_name
  #end
  
  #  Название класса в формате "1 A".
  #
  def full_name
    "#{self.year} #{self.letter}"
  end
end
