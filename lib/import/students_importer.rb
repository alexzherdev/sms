require 'fastercsv'

class StudentsImporter
  attr_accessor :content
    
  FIELDS = { "Класс" => "student_group_name", "Фамилия" => "last_name", "Имя" => "first_name", "Отчество" => "patronymic", "Дата рождения" => "birth_date", "E-mail родителей" => "parent_email", "Домашний адрес" => "home_address" }
  
  def initialize(content)
    self.content = content
  end 
  
  def parse
    students = []
    FasterCSV.parse(self.content, :headers => true, :col_sep => ";") do |row|
      attributes = {}
      row.each do |header, value|
        attributes[FIELDS[header]] = value
      end
      students.push attributes
    end
    students
  end
end