class Term < ActiveRecord::Base
  belongs_to :year
  
  validates_presence_of :year, :start_date, :end_date
  
  #  Возвращает текущую четверть или nil.
  #
  def self.current
    Settings["current_term_id"] ? (self.find(Settings["current_term_id"]) rescue nil) : nil
  end
  
  #  Является ли эта четверть текущей.
  #
  def current?
    Settings["current_term_id"].to_i == self.id
  end
  
  #  Делает эту четверть текущей.
  #
  def make_current!
    Settings["current_term_id"] = self.id
  end
  
  #  Возвращает порядковый номер этой четверти в году (1, 2, ...).
  #
  def ordinal
    self.year.terms.index(self) + 1
  end
end
