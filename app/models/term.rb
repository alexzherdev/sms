class Term < ActiveRecord::Base
  belongs_to :year
  
  validates_presence_of :year, :start_date, :end_date
  
  def self.current
    Settings["current_term_id"] ? (self.find(Settings["current_term_id"]) rescue nil) : nil
  end
  
  def current?
    Settings["current_term_id"].to_i == self.id
  end
  
  def make_current!
    Settings["current_term_id"] = self.id
  end
  
  def ordinal
    self.year.terms.index(self) + 1
  end
end
