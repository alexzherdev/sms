class StudentGroup < ActiveRecord::Base
  has_many :students, :order => "last_name ASC, first_name ASC, middle_name ASC"
  belongs_to :group_teacher, :class_name => "Teacher"
  
  default_scope :order => "year ASC, letter ASC"
  
  accepts_comma_separated_ids_for :students
  
  class << self
    def by_year(year)
      where(:year => year)
    end
  end
  
  
  #define_index do 
  #  indexes [year, letter], :as => :full_name
  #end
  
  #  Название класса в формате "1 A".
  #
  def full_name
    "#{self.year} #{self.letter}"
  end
end
