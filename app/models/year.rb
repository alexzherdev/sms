class Year < ActiveRecord::Base
  has_many :terms, :order => "start_date ASC"
  
  validates_numericality_of :start_year, :end_year, :only_integer => true, :greater_than_or_equal_to => 1900
  
  default_scope :order => "end_year DESC", :include => :terms
  
  def self.with_terms
    self.all.select { |y| y.terms.count > 0 }
  end
  
  def self.add
    last_year = self.first
    start_year = last_year ? last_year.end_year : Time.now.year
    end_year = start_year + 1
    self.create :start_year => start_year, :end_year => end_year
  end  
    
  def full_name
    "#{start_year} - #{end_year}"
  end
end
