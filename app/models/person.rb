class Person < ActiveRecord::Base
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :birth_date
  
  #  Имя в формате "Жердев Алексей"
  #
  def full_name
    "#{last_name} #{first_name}"
  end
  
  def full_name_abbr
    "#{last_name} #{first_name.first}."
  end
  
end