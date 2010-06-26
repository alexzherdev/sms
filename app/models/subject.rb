class Subject < ActiveRecord::Base
  SCHOOL_YEARS = (1..11).to_a
  
  has_and_belongs_to_many :class_rooms
  has_many :teacher_subjects
  has_many :teachers, :through => :teacher_subjects
  
  validates_presence_of :name
  validates_inclusion_of :year, :in => SCHOOL_YEARS
  validates_numericality_of :hours_per_week, :only_integer => true, :greater_than_or_equal_to => 1
  
  default_scope :include => [:class_rooms]
  named_scope :by_year, lambda { |year| { :conditions => { :year => year} } }
  
  accepts_comma_separated_ids_for :teachers
  
  #define_index do
  #  indexes name
  #end
  
  def <=>(subject)
    self.name <=> subject.name
  end
end
