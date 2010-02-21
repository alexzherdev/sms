class Year < ActiveRecord::Base
  has_many :terms, :order => "start_date ASC"
  
  validates_numericality_of :start_year, :end_year, :only_integer => true, :greater_than_or_equal_to => 1900
  
  default_scope :order => "end_year DESC", :include => :terms
  
  #  Возвращает все года, в которых есть хоть одна четверть.
  #
  def self.with_terms
    self.all.select { |y| y.terms.count > 0 }
  end
  
  #  Добавляет еще один год.
  #
  def self.add
    last_year = self.first
    start_year = last_year ? last_year.end_year : Time.now.year
    end_year = start_year + 1
    self.create :start_year => start_year, :end_year => end_year
  end  
    
  #  Название учебного года в формате "2009 - 2010".
  #
  def full_name
    "#{start_year} - #{end_year}"
  end
end
