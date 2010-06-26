# coding: utf-8

require 'csv'

class StudentsImporter
  attr_accessor :content
    
  FIELDS = { "Класс" => "student_group_name", "Фамилия" => "last_name", "Имя" => "first_name", "Отчество" => "middle_name", "Дата рождения" => "birth_date", "E-mail родителей" => "parent_email", "Домашний адрес" => "home_address" }
  
  def initialize(content)
    self.content = content
  end 
  
  def parse
    students = []
    CSV.parse(self.content, :headers => true, :col_sep => ";") do |row|
      attributes = {}
      row.each do |header, value|
        attributes[FIELDS[header]] = value
      end
      students.push attributes
    end
    students
  end
end