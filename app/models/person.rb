class Person < ActiveRecord::Base
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :birth_date
  
  define_index do
    indexes first_name, last_name, patronymic
  end
  
  #  Имя в формате "Полещук Максим Александрович"
  #
  def full_name
    "#{last_name} #{first_name} #{patronymic}"
  end
  
  #  Имя в формате "Полещук М. А."
  #
  def full_name_abbr
    patronymic_short = " " + patronymic.first + "." if patronymic
    "#{last_name} #{first_name.first}.#{patronymic_short}"
  end
  
end