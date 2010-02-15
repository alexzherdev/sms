class YearMark < Mark
  belongs_to :year
  
  validates_presence_of :year
  
end
