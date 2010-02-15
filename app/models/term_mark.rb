class TermMark < Mark
  belongs_to :term
  
  validates_presence_of :term
end
