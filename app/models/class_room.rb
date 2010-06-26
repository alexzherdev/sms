class ClassRoom < ActiveRecord::Base
  has_and_belongs_to_many :subjects
  
  validates_presence_of :number
  
  accepts_comma_separated_ids_for :subjects
  
  default_scope :order => "number ASC"
  
  #define_index do
  #  indexes :number
  #end
end
