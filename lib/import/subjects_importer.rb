require 'fastercsv'

class SubjectsImporter
  attr_accessor :content
  
  FIELDS = { "Название" => "name", "Часов в неделю" => "hours_per_week", "Год обучения" => "year" }
  
  def initialize(content)
    self.content = content
  end 
  
  def parse
    subjects = []
    FasterCSV.parse(self.content, :headers => true, :col_sep => ";") do |row|
      attributes = {}
      row.each do |header, value|
        attributes[FIELDS[header]] = value
      end
      subjects.push attributes
    end
    subjects
  end
end