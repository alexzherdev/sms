class Subject < ActiveRecord::Base
  SCHOOL_YEARS = (1..11).to_a
  
  has_and_belongs_to_many :class_rooms
  
  named_scope :by_year, lambda { |year| { :conditions => { :year => year}}}
end
