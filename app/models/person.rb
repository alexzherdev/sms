class Person < ActiveRecord::Base
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :birth_date
  validates_acceptance_of :patronymic, :allow_nil => true

  define_index do
    indexes first_name, last_name, patronymic
  end
  
  def patronymic
    return "" if read_attribute("patronymic").blank?
    read_attribute("patronymic")
  end

  #  Имя в формате "Полещук Максим Александрович"
  #
  def full_name
    if patronymic.blank?
      _patronymic = ""
    else
      _patronymic = " " + patronymic
    end
    "#{last_name} #{first_name}" + _patronymic
  end
  
  #  Имя в формате "Полещук М. А."
  #
  def full_name_abbr
    if patronymic.blank?
      patronymic_short = ""
    else
      patronymic_short = " " + patronymic.first + "."
    end
    "#{last_name} #{first_name.first}.#{patronymic_short}"
  end
  
end